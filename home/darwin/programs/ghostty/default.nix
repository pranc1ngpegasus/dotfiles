{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;

    enableBashIntegration = true;

    settings = {
      theme = "Iceberg Dark";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 17;
      macos-titlebar-style = "native";
      font-feature = "-calt -dlig -liga";
    };
  };
}
