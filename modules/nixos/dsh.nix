{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  dsh = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh;
  user = config.my.primaryUser;
  home = config.users.users.${user}.home;

  tailscale = lib.getExe pkgs.tailscale;
  jq = lib.getExe pkgs.jq;

  resolveFqdn = pkgs.writeShellScript "dsh-resolve-fqdn" ''
    # tailscaled がハングすると status も返らないため、待ち続けずに再起動へ回す。
    ${pkgs.coreutils}/bin/timeout 10 ${tailscale} status --json 2>/dev/null \
      | ${jq} -r '
        if .BackendState == "Running" and (.Self.DNSName // "") != "" then
          .Self.DNSName | rtrimstr(".")
        else
          empty
        end
      '
  '';

  launcher = pkgs.writeShellScript "dsh-web-launcher" ''
    set -eu

    # tailnet 名を設定に固定しないため、起動時に tailscale status から MagicDNS 名を取得する。
    fqdn="$(${resolveFqdn})"
    if [ -z "$fqdn" ]; then
      echo "dsh-web: tailscale is not running or DNSName is unavailable" >&2
      exit 1
    fi

    exec ${lib.getExe dsh} web \
      --host 127.0.0.1 \
      --port 3080 \
      --trusted-host "$fqdn" \
      --public-url "https://$fqdn/" \
      --no-open
  '';
in
{
  systemd.services.dsh-web = {
    description = "DeepSeek Harness web UI";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [
      "network-online.target"
      "tailscaled.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = user;
      Environment = [ "HOME=${home}" ];
      WorkingDirectory = home;
      ExecStart = launcher;
      Restart = "always";
      RestartSec = 5;
    };
  };

  systemd.services.dsh-tailscale-serve = {
    description = "Tailscale serve proxy for DeepSeek Harness";
    after = [
      "dsh-web.service"
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [
      "dsh-web.service"
      "network-online.target"
      "tailscaled.service"
    ];
    wantedBy = [ "multi-user.target" ];

    # Tailscale ログイン前の起動では serve が失敗する。スタート制限を無効にし、失敗時も永続リトライさせる。
    unitConfig.StartLimitIntervalSec = 0;

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${tailscale} serve --bg --https=443 http://127.0.0.1:3080";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
