{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-index-database.darwinModules.nix-index
  ];

  environment = {
    systemPackages =
      with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      [
        codex
        cursor-agent
        omp
        pi
      ]
      ++ [
        inputs.ccusage.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.ren.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
}
