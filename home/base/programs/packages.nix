{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      comma
      docker
      docker-buildx
      docker-compose
      fh
      gh
      ghq
      httpie
      jq
      mmv-go
      mosh
      ripgrep
    ];
  };
}
