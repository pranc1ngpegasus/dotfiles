# Determinate Nix による Nix の構成

このリポジトリの macOS と NixOS は、どちらも Determinate Nix を土台にしている。Determinate Nix は FlakeHub 連携と Determinate Nixd を組み込んだ Nix の配布で、flake input の `determinate` を通して宣言的に構成できる。ここでは両 OS で共通して効く最適化と、OS ごとに異なる構成方法を整理する。

## 共通して効く最適化

Determinate Nix はインストール時に `/etc/nix/nix.conf` を生成し、次の設定を最初から有効にする。実際の値は `nix config show` と `cat /etc/nix/nix.conf` で確認できる。

- `substituters` に FlakeHub のキャッシュ (`https://cache.flakehub.com` と `https://edge.cache.flakehub.com`) が並ぶ。nixpkgs を FlakeHub の rolling チャンネルから取るため、事前ビルド済みの成果物を引ける可能性が高くなる
- `always-allow-substitutes = true` により、信頼されたユーザーでなくても追加の substituter を指定できる
- `lazy-trees = true` により、flake input のツリーを必要な範囲だけ展開する。大きなリポジトリの評価が速くなる
- `eval-cores = 0` と `max-jobs = auto` により、評価とビルドをマシンのコア数に合わせて並列化する
- Determinate Nixd がディスクの空き容量に応じて GC を自動実行する。そのため NixOS 側では `nix.gc.automatic` を有効にしていない
- `determinate-nixd` コマンドから `status`、`upgrade`、`fix`、`login` などを実行できる。FlakeHub CLI の `fh` も `home/base/programs/packages.nix` で導入している

`flake.nix` の nixpkgs input は FlakeHub の rolling チャンネル (`https://flakehub.com/f/NixOS/nixpkgs/0.1`) を指す。これは `github:NixOS/nixpkgs/nixpkgs-unstable` と同じ rolling の挙動を保ちながら、FlakeHub のキャッシュを引けるようにするためである。

## NixOS での構成

`modules/nixos/determinate.nix` が `inputs.determinate.nixosModules.default` を import する。このモジュールは次のことを行う。

- `nix.package` を Determinate Nix のビルドへ差し替える
- `systemd.services.nix-daemon` の起動コマンドを `determinate-nixd` のデーモンへ変え、`determinate-nixd.socket` を追加する
- 生成する nix.conf の出力先を `nix/nix.custom.conf` へリダイレクトする。Determinate が管理する `/etc/nix/nix.conf` はこのファイルを include するため、NixOS の `nix.settings` はここへ書かれる
- `determinate-nixd` 本体を systemPackages へ入れる

`modules/nixos/nix.nix` は `nix.settings` に experimental-features と trusted-users を設定し、`nix.optimise.automatic = true` でストア内の重複を解消する。GC は Determinate Nixd が行うため `nix.gc.automatic` は設定しない。

## macOS での構成

`modules/darwin/determinate.nix` が `inputs.determinate.darwinModules.default` を import する。macOS では Determinate Nix を OS 側のインストーラが管理しており、nix-darwin が `/etc/nix/nix.conf` を書くと衝突する。このモジュールは次のことを行う。

- `nix.enable = lib.mkForce false` を設定し、nix-darwin に nix.conf を管理させない
- `determinateNix.customSettings` を `/etc/nix/nix.custom.conf` へ書き出す
- `determinateNix.determinateNixd.*` を `/etc/determinate/config.json` へ書き出す

このリポジトリでは `determinateNix.determinateNixd.garbageCollector.strategy = "automatic"` を設定し、NixOS 側と同じく Determinate Nixd の自動 GC に任せることを明示している。

macOS では nix-darwin の `nix.settings` が使われない。設定を足したいときは `determinateNix.customSettings` に書く。

```nix
determinateNix.customSettings = {
  trusted-users = [ "@admin" ];
  cores = 0;
};
```

### 既存の macOS へ初めて適用するとき

Determinate のインストーラは `/etc/nix/nix.custom.conf` を先に作成している。nix-darwin がこのファイルの管理を引き継ぐとき、内容が既知でないと `/etc` の衝突チェックで activation が中断する。

```text
error: Unexpected files in /etc, aborting activation
The following files have unrecognized content and would be overwritten:

  /etc/nix/nix.custom.conf
```

まず中身を確認し、自分で追加した設定が無ければ一度だけ退避してから再適用する。

```bash
sudo cat /etc/nix/nix.custom.conf
sudo mv /etc/nix/nix.custom.conf{,.before-nix-darwin}
darwin-rebuild switch --flake .#M4MacBookAir
```

設定が入っていた場合は、先に `determinateNix.customSettings` へ移してから退避する。`/etc/nix/nix.conf` は `!include nix.custom.conf` で読み込んでおり、`!include` はファイルが無くても失敗しないため、退避しても Nix は動き続ける。適用後はこのファイルが nix-darwin の生成物へ置き換わり、追記は `determinateNix.customSettings` に一本化される。

## native Linux builder (任意)

Determinate Nix は Apple Silicon 上で Linux の derivation をビルドする native Linux builder を提供する。このリポジトリでは有効化していない。使うときは `modules/darwin/determinate.nix` に次を足す。

```nix
determinateNix.determinateNixd.builder.state = "enabled";
```

`builder.state` には `"enabled"` か `"disabled"` を指定できる。ビルド用の VM には既定で 8 GiB のメモリを確保し、CPU 数は 1 になる。メモリは `builder.memoryBytes` で変えられる。CPU 数 (`builder.cpuCount`) は変更が推奨されていない。常時使わない場合は、メモリを消費するため有効化しない方がよい。

## 状態を確認する

```bash
nix --version
determinate-nixd status
nix config show
cat /etc/nix/nix.conf
cat /etc/determinate/config.json
```

`/etc/nix/nix.conf` の先頭には Determinate が生成したファイルであり上書きされることが書かれている。手で編集せず、macOS は `determinateNix.customSettings`、NixOS は `nix.settings` を編集する。
