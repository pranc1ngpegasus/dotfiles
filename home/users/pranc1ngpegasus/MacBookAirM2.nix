{...}: {
  imports = [
    ../../features/bat.nix
    ../../features/cli.nix
    ../../features/fzf.nix
    ../../features/git.nix
    ../../features/lazygit.nix
    ../../features/neovim
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
    user.signingKey = "/Users/pranc1ngpegasus/.ssh/id_ed25519.pub";
  };
}
