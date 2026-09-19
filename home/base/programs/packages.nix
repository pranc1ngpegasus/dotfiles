{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      comma
      docker
      docker-buildx
      docker-compose
      eternal-terminal
      fh
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
