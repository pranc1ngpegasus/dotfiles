{
  inputs,
  pkgs,
  ...
}:
let
  ori = pkgs.stdenv.mkDerivation {
    pname = "ori";
    version = "0.14.1";
    src = pkgs.fetchurl {
      url = "https://github.com/OpenRouterLabs/ori-releases/releases/download/cli-0.14.1-5bb4241/ori-darwin-arm64";
      hash = "sha256-MZQnC2cSmwk5qWt5IV4Tg+eDx1t2jsfMGx3ijAWSLDQ=";
    };
    dontUnpack = true;
    installPhase = ''
      install -Dm755 $src $out/bin/ori
    '';
  };
in
{
  environment = {
    systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      codex
      cursor-agent
      grok
      ori
    ];
  };
}
