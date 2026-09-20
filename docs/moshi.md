# Moshi からのリモート接続

Moshi は iPhone や iPad から SSH と mosh でホストへ接続し、その上で AI エージェントを操作するためのアプリである。Tailscale 連携は OS 層で完結するため、アプリ側に Tailscale 用の設定は無く、tailnet 内のホストは通常の SSH / mosh 接続先として扱われる。ここでは、このフレーク管理下の NixOS ホストを Moshi の接続先にするために必要な構成を説明する。

## Moshi がホストへ要求するもの

- SSH サーバーが待ち受けていること。Moshi は鍵認証で接続する
- mosh を使う場合は `mosh-server` が、セッションを維持する場合は `tmux` が、いずれも非対話の SSH セッションから見える `PATH` 上にあること
- `moshi-hook` がホストにインストールされていること
- Tailscale SSH が無効であること

## NixOS ホスト側の構成

SSH は `modules/nixos/openssh.nix` で有効化し、パスワード認証と keyboard-interactive 認証を無効にして公開鍵認証のみを使う。Tailscale の UDP ポートは `modules/nixos/networking.nix` で 60000-61000 を開放済みである。

`mosh-server` と `tmux` は home-manager のプロファイルで導入している。NixOS の `environment.profiles` には `/etc/profiles/per-user/$USER` が含まれ、このディレクトリは PAM の `PATH` (`/etc/pam/environment`) にも並ぶ。そのため、非対話の SSH セッションからも両方のコマンドをそのまま解決できる。追加の `PATH` 設定は不要である。

## moshi-hook の導入

`moshi-hook` は nixpkgs にも `llm-agents.nix` にも存在しないため、`home/linux/moshi-hook.nix` で公式 CDN のビルド済みバイナリを固定して導入している。バージョンを上げるときは、このファイルの `version` と各プラットフォームの `hash` を書き換える。新しいバージョンの hash は次のコマンドで取得できる。

```bash
nix store prefetch-file --json --hash-type sha256 \
  https://cdn.getmoshi.app/hook/v<version>/moshi-hook_Linux_x86_64.tar.gz
```

公式の `moshi-hook service install` は systemd ユニットを命令的に書き込むため、ユニットはこのモジュールで宣言的に定義している。これにより配置が世代管理の対象になる。

なお、`moshi-hook` 自身が持つ自己更新機能は、ストアのパスを書き換えられないため利用できない。更新は flake の変更として行う。

## 接続手順

### 1. ホストをペアリングする

Moshi アプリの接続先にするホストで、Easy Pair 用の QR コードを表示する。

```bash
moshi-hook host setup
```

`host setup` は tailscale CLI を調べ、デーモンが動いていれば MagicDNS 名を優先して QR コードに埋め込む。表示された QR コードを Moshi のオンボーディング画面から読み取ると、アプリ側で Ed25519 鍵が生成され、その公開鍵がホストの `authorized_keys` へ追加される。鍵認証は `authorized_keys` を経由するため、この経路は Tailscale SSH ではなく通常の `sshd` を使う必要がある。

### 2. エージェントフックを導入する

エージェントのイベントを Moshi へ届けるには、アプリ側で発行したトークンを使ってペアリングする。

```bash
moshi-hook pair --token <token>
moshi-hook install
```

トークンは Moshi アプリの設定画面から取得する。`install` は対応する各エージェントのフック設定を書き込む。

### 3. デーモンの状態を確認する

デーモンは home-manager が配置した systemd ユーザーサービスとして起動する。

```bash
systemctl --user status moshi-hook
moshi-hook status
```

## Tailscale SSH を無効にする

Tailscale SSH は、tailscaled 自身が tailnet からのポート 22 を引き受けて認証する機能である。有効になっていると、Moshi が `authorized_keys` に追加した鍵による接続が `sshd` に届かず、接続が約 60 秒止まったのちに認証エラーになる。`moshi-hook host setup` は有効化を検出するとペアリングを拒否する。

現在の設定では `tailscale up` に `--ssh` を渡していないため無効になっている。状態は次のコマンドで確認できる。`RunSSH` が `true` なら無効化する。

```bash
tailscale debug prefs | grep RunSSH
sudo tailscale set --ssh=false
```

## mosh の注意点

- mosh は最初に SSH で接続し、以降を UDP でやり取りする。ホスト側で UDP 60000-61000 を開放しておく必要がある
- mosh は UDP を使うため、TCP しか通らない制限付きネットワークでは確立できない。その場合は Moshi の接続タイプを SSH に固定する
- 接続先にこのホストのロケールが無い場合、"The locale requested by ... isn't available" のエラーが出ることがある。`LANG=en_US.UTF-8 mosh user@host` のようにロケールを明示して接続する

## 参考

- [Tailscale 経由の mosh 接続](tailscale-mosh.md)
- [Moshi 公式ドキュメント](https://getmoshi.app/docs/tailscale)
