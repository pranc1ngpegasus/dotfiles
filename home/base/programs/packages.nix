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
      google-cloud-sdk
      gws
      httpie
      jq
      lazygit
      mmv-go
      mosh
      ripgrep
    ];
  };
}
