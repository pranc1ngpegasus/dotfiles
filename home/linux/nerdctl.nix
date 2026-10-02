{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerdctl
  ];
}
