{pkgs, ...}: {
  imports = [
    ../../modules/darwin
  ];

  environment = {
    systemPackages = with pkgs; [
      awscli
      claude-code
    ];
  };

  networking = {
    hostName = "M4MacBookAir";
  };

  system = {
    primaryUser = "pranc1ngpegasus";
  };

  users.users.pranc1ngpegasus = {
    name = "pranc1ngpegasus";
    home = "/Users/pranc1ngpegasus";
  };
}
