{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [ "root" ];

  # GC は determinate-nixd がディスク空き容量に応じて自動実行するため、ここでは有効化しない。
  nix.optimise.automatic = true;

  time.timeZone = "Asia/Tokyo";
}
