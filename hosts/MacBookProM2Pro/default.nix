{...}: {
  imports = [
    ../../modules/darwin
    ../../darwin/common/users/temma.fukaya
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
