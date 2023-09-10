{...}: {
  imports = [
    ../../common/global
    ../../common/optional
    ../../common/users/temma.fukaya
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
    };
  };

  networking = {
    hostName = "adminnoMacBook-Pro";
  };
}
