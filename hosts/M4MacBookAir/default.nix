{...}: {
  imports = [
    ../../modules/darwin
  ];

  networking = {
    hostName = "M4MacBookAir";
  };

  system = {
    primaryUser = "pranc1ngpegasus";
  };

  users.users.pranc1ngpegasus = {
    name = "pranc1ngpegasus";
    home = "/Users/pranc1ngpegasus";
  };
}
