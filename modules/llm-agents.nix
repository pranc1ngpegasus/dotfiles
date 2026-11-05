{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok
    pkgs.skills
  ];
}
