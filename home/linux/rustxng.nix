{
  config,
  lib,
  pkgs,
  ...
}:
{
  systemd.user.services.rustxng = {
    Unit.Description = "RustXNG search API";
    Service = {
      ExecStart = "${lib.getExe pkgs.rustxng} --config ${config.xdg.configHome}/rustxng/settings.toml";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
