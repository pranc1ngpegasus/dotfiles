{ inputs, pkgs, ... }:
{
  environment = {
    systemPackages =
      with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      [
        codex
        cursor-agent
        grok
        opencode
      ]
      ++ [
        inputs.ccusage.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
}
