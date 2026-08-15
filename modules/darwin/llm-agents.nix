{ inputs, pkgs, ... }:
{
  environment = {
    systemPackages =
      with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      [
        codex
        cursor-agent
        grok
      ]
      ++ [
        inputs.ccusage.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.ren.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
}
