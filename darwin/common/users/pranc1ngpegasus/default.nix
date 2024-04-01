{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  home-manager = {
    users = {
      "pranc1ngpegasus" = import ../../../../home/users/pranc1ngpegasus/${config.networking.hostName}.nix;
    };
  };
}
