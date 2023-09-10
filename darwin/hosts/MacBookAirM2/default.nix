{...}: {
  imports = [
    ../../common/global
    ../../common/optional
    ../../common/users/pranc1ngpegasus
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
    };
  };

  networking = {
    hostName = "MacBookAirM2";
  };
}
