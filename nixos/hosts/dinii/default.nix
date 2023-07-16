{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.default
    ../../global
    ../../optional
    ../../users/pranc1ngpegasus
  ];

  networking = {
    hostName = "dinii";
  };
}
