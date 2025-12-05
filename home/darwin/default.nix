{...}: {
  imports = [
    ../base
  ];

  home = {
    stateVersion = "24.05";
  };

  manual = {
    manpages = {
      enable = false;
    };
  };

  targets = {
    darwin = {
      copyApps.enable = false;
      linkApps.enable = true;
    };
  };
}
