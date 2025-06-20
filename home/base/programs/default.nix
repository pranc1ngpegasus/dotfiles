{pkgs, ...}: {
  imports = [
    ./direnv
    ./git
    ./mise
    ./skim
    ./ssh
  ];
  home = {
    packages = with pkgs; [
      alejandra
      bat
      colima
      docker
      docker-compose
      gh
      ghq
      htop
      httpie
      jq
      lazygit
      mmv-go
      ni
      ripgrep
      tree
    ];
  };
}
