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

  users.users.pranc1ngpegasus = {
    name = "pranc1ngpegasus";
    home = "/Users/pranc1ngpegasus";
  };
}
