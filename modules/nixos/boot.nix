{
  boot = {
    devShmSize = "40G";
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
