{...}: {
  imports = [
    ../../modules/darwin
  ];

  networking = {
    hostName = "MacBookAirM2";
  };

  users.users.pranc1ngpegasus = {
    name = "pranc1ngpegasus";
    home = "/Users/pranc1ngpegasus";
  };
}
