{
  inputs,
  ...
}:
{
  imports = [
    inputs.quash.nixosModules.default
  ];

  nixpkgs.overlays = [
    inputs.quash.overlays.default
  ];

  services.quash = {
    enable = true;
    openFirewall = true;
  };
}
