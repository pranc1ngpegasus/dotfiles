{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-buildx
    docker-compose
  ];

  # setSocketVariable が張る DOCKER_HOST は /etc/profile への追記なので、ログイン
  # シェルを経由しない対話シェルには届かない。同じ条件でここでも張って補う。
  programs.bash.initExtra = ''
    if [ -z "''${DOCKER_HOST-}" ] && [ -n "''${XDG_RUNTIME_DIR-}" ]; then
      export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
    fi
  '';
}
