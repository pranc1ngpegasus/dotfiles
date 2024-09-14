{...}: {
  imports = [
    ../default.nix
    ./system.nix
  ];

  environment = {
    pathsToLink = ["/Applications"];
  };

  services = {
    nix-daemon.enable = true;
  };

  system = {
    stateVersion = 5;
  };
}
