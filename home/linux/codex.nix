{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  codex = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
in
{
  systemd.user = {
    services = {
      codex-app-server = {
        Unit.Description = "Codex app-server daemon with remote control";
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${lib.getExe codex} remote-control start";
          ExecStop = "${lib.getExe codex} remote-control stop";
          TimeoutStopSec = 120;
        };
        Install.WantedBy = [ "default.target" ];
      };

      # daemon は CLI が切り離して起動するため、落ちても unit は active のまま残る。
      # start を再実行して、停止した daemon を復帰させる。
      codex-app-server-healthcheck = {
        Unit.Description = "Restart the Codex app-server daemon if it stopped";
        Service = {
          Type = "oneshot";
          ExecStart = "${lib.getExe codex} remote-control start";
        };
      };
    };

    timers.codex-app-server-healthcheck = {
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
      };
    };
  };
}
