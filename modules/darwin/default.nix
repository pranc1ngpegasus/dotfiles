{ pkgs, ... }:
{
  imports = [
    ../default.nix
    ./system.nix
  ];

  environment = {
    pathsToLink = [ "/Applications" ];
    shells = [ pkgs.bashInteractive ];
  };

  system = {
    stateVersion = 5;
  };
}
