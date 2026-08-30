{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      colima
      comma
      docker
      docker-buildx
      docker-compose
      fh
      gh
      ghq
      httpie
      jq
      lazygit
      mmv-go
      mosh
      ripgrep
    ];
  };
}
