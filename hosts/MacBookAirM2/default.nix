{...}: {
  imports = [
    ../../modules/darwin
    ../../darwin/common/users/pranc1ngpegasus
  ];

  networking = {
    hostName = "MacBookAirM2";
  };

  users = {
    users = {
      pranc1ngpegasus = {
        name = "pranc1ngpegasus";
        home = "/Users/pranc1ngpegasus";
      };
    };
  };
}
