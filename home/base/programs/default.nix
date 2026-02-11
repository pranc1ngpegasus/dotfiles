{ pkgs, ... }:
{
  imports = [
    ./direnv
    ./git
    ./skim
    ./ssh
  ];
  home = {
    packages = with pkgs; [
      nixfmt
      bat
      colima
      docker
      docker-buildx
      docker-compose
      fd
      gh
      ghq
      htop
      httpie
      jq
      lazygit
      mmv-go
      ni
      nix-output-monitor
      nix-tree
      ripgrep
      tree
    ];
  };
}
