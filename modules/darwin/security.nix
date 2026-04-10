{
  networking = {
    applicationFirewall = {
      enable = true;
      blockAllIncoming = true;
    };
  };

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
  };
}
