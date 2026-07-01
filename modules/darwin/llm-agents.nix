{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-index-database.darwinModules.nix-index
  ];

  environment = {
    systemPackages = [
      inputs.codebase-memory-mcp.packages.${pkgs.system}.default
      inputs.llm-agents.packages.${pkgs.system}.antigravity-cli
      inputs.llm-agents.packages.${pkgs.system}.codex
    ];
  };
}
