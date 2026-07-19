{ config, inputs, ... }:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit inputs;
    };
    users.${config.system.primaryUser} = import ../../home/darwin;
  };
}
