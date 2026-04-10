{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;

    enableBashIntegration = true;

    settings = {
      theme = "Iceberg Dark";
      font-size = 17;
      macos-titlebar-style = "native";
      font-feature = "-calt -dlig -liga";
    };
  };
}
