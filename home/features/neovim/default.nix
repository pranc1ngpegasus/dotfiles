{
  lib,
  pkgs,
  ...
}: {
  xdg.configFile = let
    getConfigFiles = dir:
      lib.filterAttrs
      (n: _v: lib.hasSuffix ".lua" n)
      (
        lib.listToAttrs (map
          (file:
            lib.nameValuePair
            ("nvim/" + (lib.removePrefix ("${toString dir}" + "/") (toString file)))
            {
              source = file;
              executable = false;
            })
          (lib.filesystem.listFilesRecursive dir))
      );
  in
    getConfigFiles ./.;

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        gcc
        gnumake
      ];
      vimAlias = true;
    };
  };
}
