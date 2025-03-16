{pkgs, ...}: {
  imports = [
    ../../modules/darwin
  ];

  networking = {
    hostName = "M4MacBookAir";
  };

  users.users.pranc1ngpegasus = {
    name = "pranc1ngpegasus";
    home = "/Users/pranc1ngpegasus";
  };
}
