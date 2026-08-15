{ pkgs, ... }:
{
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
      mmv-go
      ripgrep
    ];
  };
}
