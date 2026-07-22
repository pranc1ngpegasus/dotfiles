# agenix による秘密情報の管理

このリポジトリでは、home-manager の agenix モジュールを使ってユーザー単位の秘密情報を復号する。暗号化した `.age` ファイルだけを `secrets/` にコミットし、復号用の秘密鍵はリポジトリの外で管理する。

## 初期設定

最初に設定を適用し、`agenix` と `age` をインストールする。

```bash
darwin-rebuild switch --flake .#M4MacBookAir
```

次に、復号専用の age 鍵を作成する。

```bash
mkdir -p ~/.config/agenix
age-keygen -o ~/.config/agenix/age.agekey
chmod 600 ~/.config/agenix/age.agekey
age-keygen -y ~/.config/agenix/age.agekey
```

最後のコマンドが出力した `age1...` 形式の公開鍵を `secrets/secrets.nix` に記載する。秘密鍵の `~/.config/agenix/age.agekey` は Git に追加せず、紛失に備えて 1Password などにバックアップする。

## 秘密情報の追加

`secrets/secrets.nix` に暗号化ファイルと公開鍵の対応を追加する。

```nix
let
  user = "age1...";
in
{
  "example.age".publicKeys = [ user ];
}
```

続いて `secrets/` に移動し、秘密情報を作成する。

```bash
cd secrets
agenix -e example.age -i ~/.config/agenix/age.agekey
```

home-manager の設定では、暗号化ファイルを次のように宣言する。

```nix
age.secrets.example.file = ../../secrets/example.age;
```

利用するプログラムには、`config.age.secrets.example.path` をファイルパスとして渡す。`builtins.readFile` で内容を読み込むと平文が Nix store に残るため、使用しない。

公開鍵を変更した場合は、秘密鍵を明示して全ファイルを再暗号化する。

```bash
cd secrets
agenix --rekey -i ~/.config/agenix/age.agekey
```
