{...}: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      accept-flake-config = true;
      warn-dirty = false;
      trusted-substituters = ["https://nix-community.cachix.org"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      # ビルドログを保持しないことでストレージを節約する
      keep-build-log = false;
      # 空き容量が 1 GiB を下回るとビルド中でも GC が走り、5 GiB まで回収する
      min-free = 1073741824; # 1 GiB
      max-free = 5368709120; # 5 GiB
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

  time = {
    timeZone = "Asia/Tokyo";
  };
}
