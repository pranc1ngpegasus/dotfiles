{...}: {
  imports = [
    ../../features/bat.nix
    ../../features/cli.nix
    ../../features/fzf.nix
    ../../features/git.nix
    ../../features/lazygit.nix
    ../../features/neovim
    ../../features/starship.nix
    ../../features/tmux.nix
    ../../features/wezterm
    ../../features/zsh.nix
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
