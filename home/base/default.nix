{ config, ... }:
{
  imports = [
    ./editor.nix
    ./programs.nix
    ./bash.nix
    ./tmux.nix
  ];

  home.sessionVariables.SCCACHE_CACHE_SIZE = "3G";

  home.file.".zshenv".text = ''
    export SCCACHE_CACHE_SIZE="${config.home.sessionVariables.SCCACHE_CACHE_SIZE}"
  '';
}
