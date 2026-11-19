{ inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age = {
    identityPaths = [ "/home/pranc1ngpegasus/.config/agenix/age.agekey" ];
    secrets = {
      # mokmok-agent は root 権限でこれを credential として読み、サービスが
      # 動くユーザーへは systemd が用意するディレクトリ経由で渡す。
      ollama-api-key = {
        file = ../../secrets/ollama-api-key.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };
      # kuroko は Linear の webhook 署名鍵をこの環境ファイルから読む。値は
      # サービスを動かすユーザーだけが読めればよい。
      kuroko-env = {
        file = ../../secrets/kuroko-env.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
