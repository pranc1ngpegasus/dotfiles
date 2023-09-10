{...}: {
  imports = [
    ./home-manager.nix
    ./nix.nix
    ./nixpkgs.nix
  ];

  environment = {
    pathsToLink = ["/Applications"];
  };

  services = {
    nix-daemon = {
      enable = true;
    };
  };
}
