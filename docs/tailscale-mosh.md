# Tailscale 経由の mosh 接続

mosh (mobile shell) は SSH ベースのリモートシェルで、ネットワークが不安定な環境でもセッションを維持できる。接続先サーバーとこの Mac の間は SSH で接続を確立し、以降のセッションは UDP でやり取りする。NAT やファイアウォール越えが得意なため、Tailscale のメッシュネットワークと組み合わせると、公共 Wi-Fi など不安定な回線からでも途切れにくいリモート作業ができる。

## 使用条件

- 接続元のこの Mac には `home/base/programs/packages.nix` で `mosh` がインストールされている
- 接続先サーバー側にも mosh サーバー (`mosh-server`) と SSH サーバーが必要である。このフレーク管理下の NixOS ホストでは `modules/nixos/environment.nix` で `mosh` をインストール済みである
- この Mac と接続先サーバーの両方が同じ Tailnet に参加している必要がある

Tailscale の IP (100.x.x.x) はプライベートレンジにあり、接続先サーバーの設定によっては外部から届かない場合がある。サーバー側のファイアウォールで 60000-61000 番ポート (UDP) を許可しておくと、mosh のセッションが確立しやすい。このフレーク管理下の NixOS ホストでは `modules/nixos/networking.nix` の `networking.firewall.allowedUDPPortRanges` で開放済みである。

## 接続手順

まず Tailscale が起動していることを確認する。

```bash
tailscale status
```

接続先サーバーが見えていれば、`mosh` にユーザー名とホストを指定して接続する。ホストは Tailscale の IP か、MagicDNS が有効ならホスト名 (例: `server.tailNNN.tt.ts.net`) を指定できる。

```bash
mosh user@<tailscale-ip>
mosh user@server.tailNNN.tt.ts.net
```

セッションを終了するには通常通り `exit` を打つ。切断してもセッションはサーバー側に残り、再接続すれば作業状態が復元される。

## 注意点

- mosh は最初に SSH で接続する。Tailscale の MagicDNS 名 (`*.tt.ts.net`) と Tailscale IP (`100.x.x.x`) 宛の接続には、`home/base/programs/ssh.nix` で Secure Enclave 鍵 (`~/.ssh/id_enclave_key`) による公開鍵認証の設定が済んでいる。それ以外の宛先やエージェント転送が必要な場合は `programs/ssh.nix` を調整する
- 接続先サーバーにこの Mac のロケール (LANG や LC_CTYPE で指定したもの) が存在しない場合、起動時に "The locale requested by ... isn't available" のエラーが出ることがある。その場合は `LANG=en_US.UTF-8 mosh user@host` のようにロケールを明示して接続する
- mosh はサーバー側にインストールされている必要があるため、接続先がこのフレーク管理外の場合はサーバー側に別途 `mosh` をインストールする
