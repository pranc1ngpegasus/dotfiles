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
      "pranc1ngpegasus" = {
        name = "Temma Fukaya";
        home = "/Users/pranc1ngpegasus";
      };
    };
  };

  home-manager = {
    users = {
      "pranc1ngpegasus" = ../../../home/users/pranc1ngpegasus/${config.networking.hostName}.nix;
    };
  };
}
