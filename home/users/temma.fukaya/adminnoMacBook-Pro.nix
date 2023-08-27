{...}: {
  imports = [
    ../../features/bat.nix
    ../../features/cli.nix
    ../../features/fish.nix
    ../../features/fzf.nix
    ../../features/git.nix
    ../../features/lazygit.nix
    ../../features/neovim
    ../../features/tmux.nix
    ../../features/wezterm
  ];

  manual = {
    manpages = {
      enable = false;
    };
  };

  home = {
    stateVersion = "23.11";
  };

  programs.git.extraConfig = {
    user.signingKey = "/Users/temma.fukaya/.ssh/id_ed25519.pub";
  };
}
