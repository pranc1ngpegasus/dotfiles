{
  outputs,
  pkgs,
  ...
}: {
  home = {
    sessionPath = [
      "$HOME/.tfenv/bin"
    ];

    packages = with pkgs; [
      _1password
      alejandra
      delta
      gh
      ghq
      hub
      mmv-go
      nodejs
      outputs.packages.${pkgs.system}.devenv
      ripgrep
      rustup
      tailscale
      tig
      tree
      yarn
    ];
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home-manager = {
      enable = true;
    };
  };
}
