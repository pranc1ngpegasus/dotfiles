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
      "temma.fukaya" = {
        name = "temma.fukaya";
        home = "/Users/temma.fukaya";
      };
    };
  };

  home-manager = {
    users = {
      "temma.fukaya" = import ../../../../home/users/temma.fukaya/${config.networking.hostName}.nix;
    };
  };
}

