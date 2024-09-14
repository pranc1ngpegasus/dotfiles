{...}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

  time = {
    timeZone = "Asia/Tokyo";
  };
}
