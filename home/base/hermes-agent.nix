{ inputs, pkgs, ... }:
{
  imports = [
    inputs.hermes-agent.homeManagerModules.default
  ];

  programs.hermes-agent.enable = true;

  # gateway を動かさないため、認証は agenix.nix が対話シェルへ export する
  # OLLAMA_API_KEY をそのまま使う。gateway を有効にするときは、サービスが
  # 読める環境ファイルを別に用意する必要がある。
  services.hermes-agent = {
    enable = true;
    package = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.minimal;
    settings.model = {
      provider = "ollama-cloud";
      default = "deepseek-v4-flash:1017";
    };
  };
}
