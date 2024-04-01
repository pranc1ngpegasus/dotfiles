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
      "temma.fukaya" = import ../../../../home/users/temma.fukaya/${config.networking.hostName}.nix;
    };
  };
}
