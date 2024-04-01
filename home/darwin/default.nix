{config, ...}: {
  imports = [
    ../features/bat.nix
    ../features/cli.nix
    ../features/fzf.nix
    ../features/git.nix
    ../features/gitui.nix
    ../features/lazygit.nix
    ../features/neovim
    ../features/starship.nix
    ../features/tmux.nix
    ../features/wezterm.nix
    ../features/zsh.nix
  ];

  home = {
    stateVersion = "24.05";
  };

  manual = {
    manpages = {
      enable = false;
    };
  };
}
