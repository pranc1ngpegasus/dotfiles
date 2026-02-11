{...}: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
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
