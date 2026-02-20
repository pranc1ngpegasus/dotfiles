{ inputs, ... }:
{
  imports = [
    ../base
    inputs.nix-index-database.homeModules.nix-index
  ];

  home = {
    stateVersion = "25.11";
  };

  manual = {
    manpages = {
      enable = false;
    };
  };

  targets = {
    darwin = {
      copyApps.enable = false;
      linkApps.enable = true;
    };
  };
}
