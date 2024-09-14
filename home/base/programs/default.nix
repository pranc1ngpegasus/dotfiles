{pkgs, ...}: {
  imports = [
    ./direnv
    ./fzf
    ./git
    ./mise
    ./rust
    ./ssh
  ];
  home = {
    packages = with pkgs; [
      alejandra
      bat
      gcc
      gh
      ghq
      grpcurl
      htop
      httpie
      jq
      lazygit
      mmv-go
      mold
      mycli
      nodejs
      openssl
      patchelf
      pgcli
      pkg-config
      protobuf
      ripgrep
      rustup
      sqlx-cli
      tig
      tree
    ];
  };
}
