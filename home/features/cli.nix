{
  pkgs,
  outputs,
  ...
}: {
  home = {
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = 1;
    };
    packages = with pkgs; [
      _1password
      alejandra
      delta
      gh
      ghq
      hub
      mmv-go
      outputs.packages.${pkgs.system}.devenv
      ripgrep
      rustup
      tailscale
      tig
      tree
    ];
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    go = {
      enable = true;
      package = pkgs.go_1_20;
    };

    home-manager = {
      enable = true;
    };

    jq = {
      enable = true;
    };

    zsh = {
      enable = true;
      initExtra = ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '';
    };
  };
}
