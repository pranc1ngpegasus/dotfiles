{
  config,
  pkgs,
  ...
}:

let
  # tailscaled がハングすると Tailnet への通信が復帰しなくなる。このスクリプトは
  # tailscaled の応答を確認し、無反応ならサービスを再起動して復旧させる。
  healthcheck = pkgs.writeShellScript "tailscale-healthcheck" ''
    set -u

    systemctl=${config.systemd.package}/bin/systemctl
    tailscale=${pkgs.tailscale}/bin/tailscale
    timeout=${pkgs.coreutils}/bin/timeout
    jq=${pkgs.jq}/bin/jq
    ping=${pkgs.iputils}/bin/ping

    # systemd 上で tailscaled が動いていなければ、ここでは何もしない。
    if ! "$systemctl" is-active --quiet tailscaled.service; then
      echo "tailscaled is inactive; nothing to do"
      exit 0
    fi

    # tailscaled がハングしていると 'tailscale status' も返ってこない。
    # timeout の終了コード 124 はタイムアウトを表す。
    json="$("$timeout" 5 "$tailscale" status --json 2>/dev/null)"
    status=$?
    if [ "$status" -eq 124 ]; then
      echo "tailscaled did not respond to 'tailscale status'; restarting it" >&2
      "$systemctl" restart tailscaled.service
      exit 0
    fi

    # ログアウト中や 'tailscale down' の状態では再起動しても復旧しないため、
    # バックエンドが接続済みのときだけ生存確認を行う。
    state="$(printf '%s' "$json" | "$jq" -r '.BackendState // empty' 2>/dev/null)"
    if [ "$state" != "Running" ]; then
      echo "tailscaled backend is not running (state: ''${state:-unknown}); skipping"
      exit 0
    fi

    # 100.100.100.100 は tailscaled 自身が提供する MagicDNS のアドレスなので、
    # ここへの Ping が通るかどうかでデーモンの生存を判定できる。
    if "$ping" -c 1 -W 5 100.100.100.100 > /dev/null 2>&1; then
      exit 0
    fi

    echo "tailscaled is connected but unresponsive; restarting it" >&2
    "$systemctl" restart tailscaled.service
  '';
in
{
  systemd.services.tailscale-healthcheck = {
    description = "Tailscale health check and auto-restart";
    after = [ "tailscaled.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = healthcheck;
      # ハングした tailscaled の停止には時間がかかるため、余裕を持たせる。
      TimeoutStartSec = "2min";
    };
  };

  systemd.timers.tailscale-healthcheck = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "5min";
    };
  };
}
