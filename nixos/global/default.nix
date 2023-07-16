{outputs, ...}: {
  imports = [
    ./nix.nix
    ./nixpkgs.nix
    ./locale.nix
  ];

  system = {
    autoUpgrade.enable = true;
    stateVersion = "23.05";
  };
}
