{...}: {
  imports = [
    ../../features/alacritty.nix
    ../../features/bat.nix
    ../../features/cli.nix
    ../../features/fzf.nix
    ../../features/git.nix
    ../../features/gitui.nix
    ../../features/lazygit.nix
    ../../features/neovim.nix
    ../../features/starship.nix
    ../../features/tmux.nix
    ../../features/zsh.nix
  ];

  manual = {
    manpages = {
      enable = false;
    };
  };

  home = {
    stateVersion = "24.05";
  };

  programs.git.extraConfig = {
    user.signingKey = "/Users/temma.fukaya/.ssh/id_ed25519.pub";
  };
}
