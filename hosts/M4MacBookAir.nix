{ pkgs, ... }:
let
  user = "pranc1ngpegasus";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  my.primaryUser = user;

  networking.hostName = "M4MacBookAir";

  system = {
    primaryUser = user;
    stateVersion = 5;
  };

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
    shell = pkgs.bashInteractive;
  };
}
