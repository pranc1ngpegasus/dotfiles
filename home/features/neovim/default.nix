{
  lib,
  pkgs,
  outputs,
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

  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };
}
