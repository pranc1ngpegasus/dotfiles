{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  grok = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok;
in
{
  systemd.user.services.grok-leader = {
    Unit.Description = "Grok agent leader";
    Service = {
      ExecStart = "${lib.getExe grok} agent leader --no-exit-on-disconnect --no-auto-update";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
