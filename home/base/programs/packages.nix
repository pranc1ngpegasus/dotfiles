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
      lazygit
      mmv-go
      mosh
      ripgrep
    ];
  };
}
