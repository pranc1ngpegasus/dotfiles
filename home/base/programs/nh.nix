{ config, lib, ... }:
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep-since 30d --keep 1";
    };
  };

  # Home Manager は macOS では extraArgs 全体を単一の引数として渡すため、
  # launchd が各オプションを個別の引数として nh に渡すようにする。
  launchd.agents.nh-clean.config.ProgramArguments = lib.mkForce [
    (lib.getExe config.programs.nh.package)
    "clean"
    "user"
    "--keep-since"
    "30d"
    "--keep"
    "1"
  ];
}
