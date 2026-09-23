{ lib, ... }:
{
  options.my.primaryUser = lib.mkOption {
    type = lib.types.str;
    description = "そのホストの主要ユーザー名。home-manager のユーザー割り当てに使う。";
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    time.timeZone = "Asia/Tokyo";
  };
}
