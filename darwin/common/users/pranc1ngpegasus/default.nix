{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  users = {
    users = {
      pranc1ngpegasus = {
        name = "pranc1ngpegasus";
        home = "/Users/pranc1ngpegasus";
      };
    };
  };

  home-manager = {
    users = {
      "pranc1ngpegasus" = import ../../../../home/users/pranc1ngpegasus/${config.networking.hostName}.nix;
    };
  };
}
