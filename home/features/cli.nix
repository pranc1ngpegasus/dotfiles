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
      delta
      deno
      fnm
      gh
      ghq
      jq
      mmv-go
      nodejs
      outputs.packages.${pkgs.system}.bunV1
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
