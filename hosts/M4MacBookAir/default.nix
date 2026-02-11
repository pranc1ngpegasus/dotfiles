{ ... }:
{
  imports = [
    ../../modules/darwin
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
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
