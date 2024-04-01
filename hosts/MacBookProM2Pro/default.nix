{...}: {
  imports = [
    ../../modules/darwin
  ];

  networking = {
    hostName = "MacBookProM2Pro";
  };

  users = {
    users = {
      "temma.fukaya" = {
        name = "temma.fukaya";
        home = "/Users/temma.fukaya";
      };
    };
  };
}
