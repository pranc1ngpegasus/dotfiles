_: {
  imports = [
    ./options.nix
    ./agenix.nix
    ./agent-browser.nix
    ./editor.nix
    ./locale.nix
    ./programs.nix
    ./bash.nix
    ./tmux.nix
  ];

  home.stateVersion = "26.11";
}
