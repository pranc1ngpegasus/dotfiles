{ ... }:
{
  imports = [
    ../default.nix
    ./system.nix
  ];

  environment = {
    pathsToLink = [ "/Applications" ];
  };

  system = {
    stateVersion = 5;
  };
}
