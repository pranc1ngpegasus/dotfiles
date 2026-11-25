# Grok の agent leader を systemd ユーザーサービスで常駐させる

`home/linux/grok-leader.nix` は `grok-leader.service` を定義する。サービスは `inputs.llm-agents` が配布する `grok` を `agent leader --no-exit-on-disconnect --no-auto-update` で起動し、systemd のユーザーサービスとして動かし続ける。ユニットは `default.target` に属するため、ユーザーマネージャが起動すると自動で立ち上がる。

TUI が起動する leader は最後のクライアントが切断した時点で終了する。そのため複数のクライアントで 1 つの leader を共有できない。`--no-exit-on-disconnect` を渡すと、すべてのクライアントが切断しても leader は動き続ける。

`--no-auto-update` は leader の更新確認を止める。Nix store のバイナリは自身を書き換えられないため、更新は `nixos-rebuild switch` で新しい世代に切り替えて反映する。`llm-agents` のラッパーも `GROK_DISABLE_AUTOUPDATER=1` を設定している。

leader は `~/.grok/leader.sock` で待ち受ける。対話的なクライアントが既定で使うパスと同じなので、サービスが動いている間はクライアントがそのまま接続する。

## リソースの上限

leader はセッションの推論とサブエージェントの実行を抱えるため、ほかのユーザーサービスより大きなメモリを使う。そこでサービスは既定の `app.slice` ではなく、専用の `grok-leader.slice` の中で動かす。スライスを分けると、leader とその子プロセスのメモリとタスクがほかのユーザーサービスと混ざらずに計上され、上限も leader だけに掛かる。leader が暴走しても、同じスライスにいるプロセスだけが影響を受ける。

`home/linux/grok-leader.nix` は `grok-leader.slice` に次の値を設定している。

- `MemoryHigh=40G` はソフトリミットである。使用量がこの値を超えるとカーネルが回収を強め、プロセスを止めずに速度を落として抑え込む
- `MemoryMax=48G` はハードリミットである。この値を超えるとスライス内のプロセスは OOM killer の対象になる
- `TasksMax=4096` はスライス内で同時に存在できるタスク (プロセスとスレッド) の上限である

サービス側は `Service.Slice = "grok-leader.slice"` だけを指定している。systemd は `Slice=` を見ると、そのスライスへの `Requires=` と `After=` を自動で追加する。そのためスライスはサービスと一緒に起動し、スライス側に `WantedBy` を書く必要はない。

使用状況は `systemctl --user status grok-leader.slice` で確認できる。値だけを読むときは `systemctl --user show grok-leader.slice -p MemoryCurrent -p MemoryHigh -p MemoryMax -p TasksCurrent -p TasksMax` を使う。

`CPUAccounting=yes` は書いていない。現在の systemd ではスライスの CPU アカウンティングが常に有効で、この設定を書くと警告を出して無視するためである。

## 操作

`systemctl --user status grok-leader` でサービスの状態を確認し、`journalctl --user -u grok-leader` で systemd のログを読む。`grok leader list` は起動中の leader を一覧し、`grok leader info` は leader の情報を表示する。

`systemctl --user stop grok-leader` でサービスを止めると、次に leader を必要としたクライアントが自分の leader を起動する。その leader は最後のクライアントが切断したときに終了するので、サービスを入れる前の挙動に戻る。

サービスを入れる前にクライアントが起動した leader が `~/.grok/leader.sock` を保持していると、サービスはソケットを取れずに再起動を繰り返す。その場合は `systemctl --user stop grok-leader`、`grok leader kill`、`systemctl --user start grok-leader` の順に実行する。

## 変更を反映する

リポジトリのルートで `sudo nixos-rebuild switch --flake .#nixos` を実行する。home-manager の activation がユニットを `~/.config/systemd/user` に配置し、`default.target` に属するユニットを起動する。

## 認証情報

`home/linux/grok-leader.nix` は home-manager の agenix が `$XDG_RUNTIME_DIR/agenix/ollama-api-key` に展開する `OLLAMA_API_KEY` を読んでから leader を起動する。`~/.grok/config.toml` のモデル定義は `env_key = "OLLAMA_API_KEY"` を指定しているが、この環境変数を解決するのは推論を実行するプロセスである。leader がセッション本体の推論を実行するため、キーを持たない leader ではリクエストに認証ヘッダが付かず 401 になる。クライアントが持つキーはサブエージェントには渡るが、leader のメインターンには渡らない。

`Unit.After` と `Unit.Wants` に `agenix.service` を指定しているのは、秘密情報のマウントが終わる前にキーを読まないようにするためである。キーを読めない場合、スクリプトは `set -euo pipefail` で終了し、サービスは再起動を繰り返す。無認証のまま起動して 401 を返し続けるより、起動の失敗として気付けるほうがよい。

キーが解決できない場合、grok はセッションの OIDC トークンを第三者エンドポイントへ送らない。そのため、ログに `Auth: Oidc` と出ていても実際にはキーが送られておらず、Ollama は未認証として 401 を返す。grok はこれを「Authentication temporarily unavailable」と表示して再試行を促すが、この場合は環境変数の欠落が原因なので再試行では直らない。
