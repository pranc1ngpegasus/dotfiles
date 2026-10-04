{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      comma
      fh
      gh
      gh-stack
      ghq
      httpie
      jq
      mmv-go
      mosh
      ripgrep
    ];
  };
}
