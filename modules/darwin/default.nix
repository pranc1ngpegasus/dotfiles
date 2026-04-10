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

  fonts = {
    packages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };

  system = {
    stateVersion = 5;
  };
}
