{...}: {
  security = {
    pam = {
      services = {
        sudo_local = {
          touchIdAuth = true;
        };
      };
    };
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 3.0;
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSDisableAutomaticTermination = false;
        NSTextShowsControlCharacters = true;
      };

      alf = {
        globalstate = 1;
      };

      menuExtraClock = {
        IsAnalog = true;
      };

      dock = {
        autohide = true;
        mru-spaces = false;
        minimize-to-application = true;
        show-process-indicators = true;
        show-recents = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = false;
        FirstClickThreshold = 1;
        SecondClickThreshold = 1;
        TrackpadRightClick = true;
      };
    };
  };
}
