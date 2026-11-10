{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  grok = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok;

  # セッション本体の推論は leader が実行するため、クライアントではなく leader の
  # 環境で env_key を解決できる必要がある。
  startLeader = pkgs.writeShellScript "grok-leader" ''
    set -euo pipefail
    export OLLAMA_API_KEY="$(< "$XDG_RUNTIME_DIR/agenix/ollama-api-key")"
    exec ${lib.getExe grok} agent leader --no-exit-on-disconnect --no-auto-update
  '';
in
{
  systemd.user.services.grok-leader = {
    Unit = {
      Description = "Grok agent leader";
      After = [ "agenix.service" ];
      Wants = [ "agenix.service" ];
    };
    Service = {
      ExecStart = startLeader;
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
