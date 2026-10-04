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

## クリップボードの共有

接続先の tmux でコピーした内容は、OSC 52 という端末のエスケープシーケンスで手元の Mac のクリップボードに入る。tmux は `set-clipboard on` が有効なとき、コピーした内容を OSC 52 としてクライアントの端末へ書き出す。Ghostty は OSC 52 による書き込みを既定で許可するので、間に mosh が入っていても Mac のクリップボードがそのまま更新される。mosh は端末の出力を中継するだけなので、この経路は SSH で接続した場合と同じように働く。

mosh は接続先の `TERM` を `xterm-256color` に設定する (`mosh-server` の仕様)。tmux は `xterm-256color` を clipboard 対応の端末として扱うため、mosh で接続する分には追加の設定なしに OSC 52 が送られる。接続元の tmux の中から SSH で入ると `TERM` は `tmux-256color` になるため、`home/base/tmux.nix` の `terminal-features` でこの端末にも clipboard を教えている。

コピーの方法は次のとおりである。

- コピーモードで範囲を選んで `y` を押すと、tmux のバッファに入り、同時に Mac のクリップボードが更新される
- 接頭キー (C-q) の後に `Y` を押すと、現在のペインのディレクトリが同じ経路でコピーされる
- 接続先の Neovim は `$TMUX` があるとき tmux をクリップボードプロバイダに選ぶ。`vim.opt.clipboard = "unnamed"` の設定と合わせて、ヤンクは `tmux load-buffer -w` から OSC 52 で Mac に届く

Mac でコピーした内容を接続先で使うときは、端末のペースト (Cmd+V) を使う。接続先の Neovim の `"*p` は tmux のバッファを読むため、Mac 側でコピーした内容はここには現れない。OSC 52 の読み取りを使えば Mac のクリップボードを読めるが、Ghostty は `clipboard-read` の既定値 `ask` により確認を求める。

`xsel` と `xclip` は X11 の、`wl-copy` は Wayland のクリップボードを操作するコマンドである。mosh や SSH で接続しただけのセッションにはこれらの表示サーバーが無いので、`xsel: Can't open display` のように失敗する。`home/base/tmux.nix` は表示サーバーがある環境 (NixOS を直接操作する場合など) のためにこれらをインストールし、tmux-yank のコピーコマンドを表示サーバーの有無で切り替えている。表示サーバーが無いときは tmux の OSC 52 経由で書き込む。

## 注意点

- mosh は最初に SSH で接続する。Tailscale の MagicDNS 名 (`*.tt.ts.net`) と Tailscale IP (`100.x.x.x`) 宛の接続には、`home/base/programs/ssh.nix` で Secure Enclave 鍵 (`~/.ssh/id_enclave_key`) による公開鍵認証の設定が済んでいる。それ以外の宛先やエージェント転送が必要な場合は `programs/ssh.nix` を調整する
- 接続先サーバーにこの Mac のロケール (LANG や LC_CTYPE で指定したもの) が存在しない場合、起動時に "The locale requested by ... isn't available" のエラーが出ることがある。その場合は `LANG=en_US.UTF-8 mosh user@host` のようにロケールを明示して接続する
- mosh はサーバー側にインストールされている必要があるため、接続先がこのフレーク管理外の場合はサーバー側に別途 `mosh` をインストールする
