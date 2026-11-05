{ pkgs, ... }:
let
  serve = pkgs.writeShellScript "dsh-web-tailscale-serve" ''
    # tailscaled はバックエンドが Running になるまで serve の設定を拒むため、
    # 起動が重なると最初の試行は失敗する。成功するまで待つ。
    for _ in $(${pkgs.coreutils}/bin/seq 60); do
      if ${pkgs.tailscale}/bin/tailscale serve --bg --yes --https=443 http://127.0.0.1:3080; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 5
    done

    echo "tailscale serve を設定できませんでした。tailscaled の状態を確認してください" >&2
    exit 1
  '';

  unserve = pkgs.writeShellScript "dsh-web-tailscale-unserve" ''
    # ハンドラが既に消えていると off は非ゼロで終わるので、停止は失敗させない。
    ${pkgs.tailscale}/bin/tailscale serve --yes --https=443 off || true
  '';
in
{
  systemd.services.dsh-web-tailscale-serve = {
    description = "Publish dsh web on the tailnet over HTTPS";
    wantedBy = [ "multi-user.target" ];
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "6min";
      ExecStart = serve;
      ExecStop = unserve;
    };
  };
}
