{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  dsh = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh;

  # dsh は trusted-host と public-url を待ち受け名に合わせる必要がある。tailnet から
  # 見た名前は MagicDNS 名なので、起動のたびに tailscale status から取り直す。
  start = pkgs.writeShellScript "dsh-web-start" ''
    if ! status=$(${lib.getExe' pkgs.coreutils "timeout"} 5 ${lib.getExe pkgs.tailscale} status --json); then
      echo "tailscale status が失敗したため、dsh web を起動できません" >&2
      exit 1
    fi

    authority=$(${lib.getExe pkgs.jq} -r '.Self.DNSName // empty' <<< "$status")
    authority=''${authority%.}

    if [ -z "$authority" ]; then
      echo "MagicDNS 名を取得できなかったため、dsh web を起動できません" >&2
      exit 1
    fi

    exec ${lib.getExe dsh} web \
      --host 127.0.0.1 \
      --port 3080 \
      --no-open \
      --trusted-host "$authority" \
      --public-url "https://$authority/"
  '';
in
{
  systemd.user.services.dsh-web = {
    Unit.Description = "dsh web";
    Service = {
      ExecStart = start;
      WorkingDirectory = "%h";
      Restart = "on-failure";
      RestartSec = 10;
      TimeoutStopSec = 15;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
