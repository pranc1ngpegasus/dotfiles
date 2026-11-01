{
  config,
  lib,
  pkgs,
  ...
}:
{
  launchd.agents.rustxng = {
    enable = true;
    config = {
      ProgramArguments = [
        (lib.getExe pkgs.rustxng)
        "--config"
        "${config.xdg.configHome}/rustxng/settings.toml"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/rustxng.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/rustxng.log";
    };
  };
}
