{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      btop
      fh
      gh
      ghq
      jq
      lazygit
      mmv-go
      mosh
      ripgrep
    ];
  };
}
