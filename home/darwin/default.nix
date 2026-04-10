{ inputs, pkgs, ... }:
{
  imports = [
    ../base
    inputs.nix-index-database.homeModules.nix-index
  ];

  home = {
    stateVersion = "25.11";

    # macOS でのみ利用するパッケージ。ghostty-bin は公式 .dmg の再パッケージで、
    # Nix で macOS からソースビルドできないため bin 版を使う。
    packages = with pkgs; [
      ghostty-bin
    ];
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
