{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      comma
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
