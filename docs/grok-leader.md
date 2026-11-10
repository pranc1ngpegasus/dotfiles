# Grok の agent leader を systemd ユーザーサービスで常駐させる

`home/linux/grok-leader.nix` は `grok-leader.service` を定義する。サービスは `inputs.llm-agents` が配布する `grok` を `agent leader --no-exit-on-disconnect --no-auto-update` で起動し、systemd のユーザーサービスとして動かし続ける。ユニットは `default.target` に属するため、ユーザーマネージャが起動すると自動で立ち上がる。

TUI が起動する leader は最後のクライアントが切断した時点で終了する。そのため複数のクライアントで 1 つの leader を共有できない。`--no-exit-on-disconnect` を渡すと、すべてのクライアントが切断しても leader は動き続ける。

`--no-auto-update` は leader の更新確認を止める。Nix store のバイナリは自身を書き換えられないため、更新は `nixos-rebuild switch` で新しい世代に切り替えて反映する。`llm-agents` のラッパーも `GROK_DISABLE_AUTOUPDATER=1` を設定している。

leader は `~/.grok/leader.sock` で待ち受ける。対話的なクライアントが既定で使うパスと同じなので、サービスが動いている間はクライアントがそのまま接続する。

## 操作

`systemctl --user status grok-leader` でサービスの状態を確認し、`journalctl --user -u grok-leader` で systemd のログを読む。`grok leader list` は起動中の leader を一覧し、`grok leader info` は leader の情報を表示する。

`systemctl --user stop grok-leader` でサービスを止めると、次に leader を必要としたクライアントが自分の leader を起動する。その leader は最後のクライアントが切断したときに終了するので、サービスを入れる前の挙動に戻る。

サービスを入れる前にクライアントが起動した leader が `~/.grok/leader.sock` を保持していると、サービスはソケットを取れずに再起動を繰り返す。その場合は `systemctl --user stop grok-leader`、`grok leader kill`、`systemctl --user start grok-leader` の順に実行する。

## 変更を反映する

リポジトリのルートで `sudo nixos-rebuild switch --flake .#nixos` を実行する。home-manager の activation がユニットを `~/.config/systemd/user` に配置し、`default.target` に属するユニットを起動する。

## 認証情報

モデルの API 認証情報はクライアントが供給する。`OLLAMA_API_KEY` を持たない leader に、そのキーを持つクライアントからプロンプトを送ると応答が返ることを 2026-11-10 に確認した。そのためユニットはキーを転送しない。キーを持たないクライアントは、サービスが動いていても 401 で失敗する。
