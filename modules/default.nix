{ ... }:
{
  nix = {
    enable = false;
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

  time = {
    timeZone = "Asia/Tokyo";
  };
}
