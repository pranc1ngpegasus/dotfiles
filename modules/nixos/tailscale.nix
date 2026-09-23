{ config, lib, ... }:
let
  # dsh の Web UI が待ち受けるポート。home/linux/dsh-web.nix の dsh-web サービスが
  # 同じポートで待ち受けるため、変更するときは両方を揃える。
  dshWebPort = 3080;
in
{
  services.tailscale.enable = true;

  # dsh の Web UI を tailnet 内にだけ公開する。tailscaled がログインしていない間は
  # serve 設定を書き込めないため、失敗したら再試行する。
  systemd.services.tailscale-serve = {
    description = "Publish the dsh web UI to the tailnet with Tailscale Serve";

    wantedBy = [ "multi-user.target" ];
    wants = [ "tailscaled.service" ];
    after = [ "tailscaled.service" ];

    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "10s";
    };

    script = "${lib.getExe config.services.tailscale.package} serve --bg ${toString dshWebPort}";
  };
}
