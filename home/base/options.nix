{ lib, ... }:
{
  options.my = {
    ssh.identityFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SSH の公開鍵認証に使う秘密鍵のパス。未設定なら IdentityFile を指定しない。";
    };

    git.signingKey = lib.mkOption {
      type = lib.types.str;
      description = "Git のコミット署名に使う SSH 鍵のパス。";
    };
  };
}
