{ inputs, ... }:
{
  imports = [
    ./options.nix
    ./agenix.nix
    ./editor.nix
    ./locale.nix
    ./programs.nix
    ./bash.nix
    ./tmux.nix
    inputs.nix-index-database.homeModules.nix-index
  ];

  home.stateVersion = "26.11";
}
