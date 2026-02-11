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
      colima
      docker
      docker-buildx
      docker-compose
      gh
      ghq
      httpie
      jq
      lazygit
      mmv-go
      ripgrep
    ];
  };
}
