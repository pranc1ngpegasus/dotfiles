{pkgs, ...}: {
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

  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
        ];
      })
    ];
  };

  networking = {
    hostName = "MacBookAirM2";
  };
}
