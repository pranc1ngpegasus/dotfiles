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
        name = "Temma Fukaya";
        home = "/Users/temma.fukaya";
      };
    };
  };

  home-manager = {
    users = {
      "temma.fukaya" = ../../../home/users/temma.fukaya/${config.networking.hostName}.nix;
    };
  };
}
