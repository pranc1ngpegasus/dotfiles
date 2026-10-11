{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      awscli2
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
