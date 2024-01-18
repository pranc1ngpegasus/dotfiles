{
  lib,
  pkgs,
  ...
}: {
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      extraLuaConfig = lib.fileContents ./init.lua;
      extraPackages = with pkgs; [
        gcc
        gnumake
      ];
      vimAlias = true;
    };
  };
}
