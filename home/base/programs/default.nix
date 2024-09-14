{pkgs, ...}: {
  imports = [
    ./direnv
    ./fzf
    ./git
    ./mise
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
      sqlx-cli
      tig
      tree
    ];
  };
}
