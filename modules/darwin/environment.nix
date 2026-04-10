{ pkgs, ... }:
{
  environment = {
    pathsToLink = [ "/Applications" ];
    shells = [ pkgs.bashInteractive ];
  };
}
