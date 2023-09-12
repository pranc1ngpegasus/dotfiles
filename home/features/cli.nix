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
      fnm
      gh
      ghq
      hub
      jq
      mmv-go
      nodejs
      outputs.packages.${pkgs.system}.devenv
      ripgrep
      rustup
      skim
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
