{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerdctl
  ];

  programs.bash.shellAliases.docker = "nerdctl";
}
