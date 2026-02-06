{pkgs, ...}: {
  imports = [
    ./direnv
    ./git
    ./mise
    ./skim
    ./ssh
  ];
  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
      style = "numbers,changes";
    };
  };
  home = {
    packages = with pkgs; [
      alejandra
      colima
      docker
      docker-buildx
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
