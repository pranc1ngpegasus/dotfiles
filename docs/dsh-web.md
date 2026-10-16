# Tailscale 経由の DeepSeek Harness

DeepSeek Harness (`dsh`) はエージェントハーネスで、`dsh web` がブラウザー用の UI を提供する。このホストでは shiguredo の fork をビルドし、systemd サービスとしてループバックで動かす。tailnet 側の窓口は nginx が担い、`http://nixos.tail9103a.ts.net:3080/` を開けば Settings を含めてそのまま使える。fork は日本語ロケール、フォント設定、ブランチ表示、Ollama Cloud 対応を追加したものである。

## 構成

```mermaid
graph LR
  mac["Mac のブラウザー"] -->|"http://nixos.tail9103a.ts.net:3080/"| nginx["nginx (0.0.0.0:3080, tailscale0 のみ開放)"]
  nginx -->|"Host をそのまま渡す"| dsh["dsh web (127.0.0.1:3081)"]
  loopback["Mac のブラウザー (予備)"] -->|"ssh -N -L 3081:127.0.0.1:3081"| dsh
```

`modules/nixos/dsh-web.nix` がこの仕組み全体を管理する。fork のビルド、実行用の公式 Node.js の導入、`dsh web` の起動、nginx による中継、tailscale0 だけを対象にしたファイアウォールの開放がそこに書かれている。

dsh は `--host 0.0.0.0` を安全性のために拒否する (「it would expose remote code execution to the network; use 127.0.0.1 instead」)。そのため dsh はループバックで動かし、tailnet 側の窓口は nginx が担う。nginx はブラウザーが送った Host をポートごとそのまま渡す。dsh が発行する Cookie は URL の authority (ホストとポート) に紐付くため、ポートを落とすと 401 になる。

## tailnet の名前を特権として扱うパッチ

dsh のブラウザー UI は、ページの origin がループバックのときだけ Host の設定文書を読む。tailnet の名前で開いた画面では設定がページ内のメモリに閉じ、Settings の Models が `settings are unavailable in this browser` を返して API キーを設定できない。判定はページの URL の hostname だけで行われ (`packages/client/connection/src/client/index.ts` の `isLoopback`)、`127.0.0.1`、`localhost`、`::1` と `127/8` 以外は非特権になる。

`modules/nixos/dsh-web-trusted-hosts.patch` がこの判定に、Host 側で宣言した authority (`--trusted-host`) との一致を足す。宣言は `modules/nixos/dsh-web.nix` のランチャーが tailscaled から解決した MagicDNS 名と tailnet の IP を渡している。`/api` の Host fence は元のままで、宣言していない authority のリクエストは従来どおり 401 になる。

このパッチは「tailnet の名前で開いたブラウザーがホストの設定文書を読み書きできる」ことを意味する。トークン付き URL を知る相手は設定を変更できるので、URL は意図した相手にだけ渡す。パッチは入力の改訂に固定されており、`nix flake update deepseek-harness` で改訂が変わって適用に失敗するとビルドが止まる。installCheck は `__DSH_CONNECTION_TRUSTED_HOSTS__` の目印を確認する。

## 使い方

サービスは起動のたびにトークン付きの URL をジャーナルへ出す。これを Mac のブラウザーで開けばよい。

```bash
sudo journalctl -u dsh-web | grep "dsh web:"
```

初回は Settings の Models で API キー (DeepSeek または Ollama Cloud) を設定し、Choose workspace から作業対象のディレクトリを追加する。セッションやログ、プロファイルは `~/.dsh` に置かれ、サービスは `my.primaryUser` として動く。`dsh` コマンド自体も systemPackages に入っているので、SSH から直接使える。rootless Docker の socket は `DOCKER_HOST` としてサービスにも渡している。

nginx を経由できないときは、同じサービスへ SSH ポート転送で入るループバックの面も使える。

```bash
ssh -N -L 3081:127.0.0.1:3081 nixos.tail9103a.ts.net
```

## ビルドと更新

- fork の改訂は `nix flake update deepseek-harness` で取り込み、`sudo nixos-rebuild switch --flake .#nixos` で反映する。パッチが当たらなくなったら `modules/nixos/dsh-web-trusted-hosts.patch` を現在の改訂に合わせて作り直す
- 実行には公式の Node.js (nodejs.org が配布する tarball) を使う。nixpkgs の node は静的にリンクされており、dsh が起動時に使う `node-addon-require-builtin` が必要とする V8 の内部シンボルを持たないため、`Unsupported/no-getter` で起動に失敗する
- ビルドはリポジトリ全体をビルドするので store の消費が大きい

## 検討した代替案

| 案 | 採否 | 理由 |
| --- | --- | --- |
| nginx で公開し、宣言した authority を特権にするパッチを当てる | 採用 | tailnet の URL だけで設定まで完結する。fence はそのまま |
| SSH ポート転送だけで済ませる | 不採用 | 設定はすべて使えるが、Mac 以外の端末やブラウザーから開けない |
| `--host 0.0.0.0` で直接公開する | 不採用 | CLI が安全性を理由に拒否する (実測。エラー文は上に引用した) |
| `tailscale serve` | 不採用 | この tailnet では HTTPS 証明書が有効になっていない (`CertDomains` が空) ため TLS を提供できない。設定も tailscaled の状態として保存され、Nix の宣言的な設定から外れる |
| パッチを当てずにループバックの面でだけ設定する | 不採用 | 2026-10-08 に一度この形にしたが、tailnet の URL で `settings are unavailable in this browser` に当たるため戻した |
