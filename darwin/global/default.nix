{...}: {
  imports = [
    ./nix.nix
    ./nixpkgs.nix
    ./home-manager.nix
  ];

  environment = {
    pathsToLink = ["/Applications"];
  };

  services = {
    nix-daemon.enable = true;
  };

  system = {
    stateVersion = 4;
  };
}
