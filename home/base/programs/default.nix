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
      comma
      docker
      docker-buildx
      docker-compose
      gh
      ghq
      httpie
      jq
      lazygit
      mmv-go
      octorus
      ripgrep
    ];
  };
}
