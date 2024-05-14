{
  outputs,
  pkgs,
  ...
}: {
  imports = [
    ./bat
    ./fzf
    ./git
    ./gitui
    ./lazygit
  ];

  home = {
    sessionPath = [
      "$HOME/.tfenv/bin"
      "$HOME/.cargo/bin"
    ];

    packages = with pkgs; [
      alejandra
      awscli2
      fnm
      gh
      ghq
      go
      google-cloud-sdk
      grpcurl
      htop
      httpie
      jq
      mmv-go
      mycli
      nodePackages.pnpm
      nodejs
      pgcli
      protobuf
      ripgrep
      rustup
      tig
      tree
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
