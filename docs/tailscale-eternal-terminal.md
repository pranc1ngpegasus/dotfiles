# Tailscale 経由の Eternal Terminal 接続

Eternal Terminal (ET) は SSH に似たリモートシェルで、回線が切れても TCP セッションを維持し、自動で再接続する。mosh と同じく移動中や不安定なネットワークでの作業に向いているが、UDP ではなく TCP を使うため、UDP が通らない制限付きネットワークでも利用できる。NAT やファイアウォール越えが得意な Tailscale のメッシュネットワークと組み合わせると、公共 Wi-Fi など不安定な回線からでも途切れにくいリモート作業ができる。通常の作業では [Tailscale 経由の mosh 接続](tailscale-mosh.md) を使い、UDP が使えない環境での代替経路として ET を残している。

## 使用条件

- 接続元のこの Mac には `home/base/programs/packages.nix` で `eternal-terminal` がインストールされている
- 接続先サーバー側で `services.eternal-terminal.enable` を有効化し、`etserver` が起動している必要がある
- この Mac と接続先サーバーの両方が同じ Tailnet に参加している必要がある

サーバー側のファイアウォールでは TCP の 2022 番ポートを許可する。NixOS では `services.eternal-terminal.enable` に加えて `networking.firewall.trustedInterfaces = [ "tailscale0" ]` を設定しておくと、Tailnet からの接続がそのまま通る。

## 接続手順

まず Tailscale が起動していることを確認する。

```bash
tailscale status
```

接続先サーバーが見えていれば、`et` にユーザー名とホストを指定して接続する。ホストは Tailscale の IP か、MagicDNS が有効ならホスト名 (例: `server.tailNNN.tt.ts.net`) を指定できる。

```bash
et user@<tailscale-ip>
et user@server.tailNNN.tt.ts.net
```

セッションを終了するには通常通り `exit` を打つ。回線が切れてもセッションはサーバー側に残り、`et` を再実行すれば作業状態が復元される。

## 注意点

- ET は SSH のプロトコルを使うが、ssh デーモンではなく etserver (2022 番ポート) に直接接続する。認証はサーバー側の `~/.ssh/authorized_keys` を使うため、`home/base/programs/ssh.nix` で設定した公開鍵がそのまま利用できる。ssh デーモンは必要ない
- 接続先サーバーにこの Mac のロケール (LANG や LC_CTYPE で指定したもの) が存在しない場合、起動時に "The locale requested by ... isn't available" のエラーが出ることがある。その場合は `LANG=en_US.UTF-8 et user@host` のようにロケールを明示して接続する
- ポート 2022 が他のサービスと衝突する場合は `services.eternal-terminal.port` で変更する。接続側のクライアントも同じポートを指定する必要がある
- ET は接続先サーバーにインストールされている必要があるため、接続先がこのフレーク管理外の場合はサーバー側に別途 `eternal-terminal` をインストールする
