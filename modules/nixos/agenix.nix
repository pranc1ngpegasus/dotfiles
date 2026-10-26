{ inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age = {
    identityPaths = [ "/home/pranc1ngpegasus/.config/agenix/age.agekey" ];
    secrets = {
      user-password = {
        file = ../../secrets/user-password.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      # mokmok-agent は root 権限でこれを credential として読み、サービスが
      # 動くユーザーへは systemd が用意するディレクトリ経由で渡す。
      ollama-api-key = {
        file = ../../secrets/ollama-api-key.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
