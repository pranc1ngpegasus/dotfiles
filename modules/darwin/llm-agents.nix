{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-index-database.darwinModules.nix-index
  ];

  environment = {
    systemPackages = [
      inputs.llm-agents.packages.${pkgs.system}.claude-code
      inputs.llm-agents.packages.${pkgs.system}.codex
      inputs.llm-agents.packages.${pkgs.system}.cursor-agent
    ];
  };
}
