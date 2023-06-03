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
      "FVFHQ1JRQ05N" = {
        name = "Temma Fukaya";
        home = "/Users/pranc1ngpegasus";
      };
    };
  };

  home-manager = {
    users = {
      "FVFHQ1JRQ05N" = ../../../home/users/pranc1ngpegasus/${config.networking.hostName}.nix;
    };
  };
}
