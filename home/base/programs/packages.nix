{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      awscli2
      btop
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
