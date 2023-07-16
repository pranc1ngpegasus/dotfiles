{config, ...}: {
  users = {
    mutableUsers = false;
    users.pranc1ngpegasus = {
      isNormalUser = true;
      createHome = true;
      home = "/home/pranc1ngpegasus";
      extraGroups = [
        "wheel"
        "docker"
        "network"
        "networkmanager"
        "git"
      ];
    };
  };

  home-manager = {
    users = {
      pranc1ngpegasus = ../../../home/users/pranc1ngpegasus/${config.networking.hostName}.nix;
    };
  };
}
