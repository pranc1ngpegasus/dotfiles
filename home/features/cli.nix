{
  outputs,
  pkgs,
  ...
}: {
  home = {
    sessionPath = [
      "$HOME/.tfenv/bin"
      "$HOME/.cargo/bin"
    ];

    packages = with pkgs; [
      _1password
      alejandra
      awscli2
      delta
      fnm
      gh
      ghq
      google-cloud-sdk
      jq
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
