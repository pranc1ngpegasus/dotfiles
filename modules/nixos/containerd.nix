{
  config,
  pkgs,
  ...
}:
let
  user = config.my.primaryUser;
  home = config.users.users.${user}.home;

  # nerdctl パッケージは bin/nerdctl とシェル補完しか同梱しておらず、rootless 用の
  # ヘルパースクリプトを含まないため、ソースツリーから取り出して配置する。
  # runCommandLocal を使うのは、ビルド結果が nerdctl のソースツリーを参照しないようにするためである。
  rootlessHelpers = pkgs.runCommandLocal "containerd-rootless-helpers" { } ''
    install -Dm755 ${pkgs.nerdctl.src}/extras/rootless/containerd-rootless.sh $out/bin/containerd-rootless.sh
    install -Dm755 ${pkgs.nerdctl.src}/extras/rootless/containerd-rootless-setuptool.sh $out/bin/containerd-rootless-setuptool.sh
  '';

  # containerd.service が active になっても、containerd-rootless.sh が child_pid を書くまで
  # には間がある。After= は containerd.service が active になった時点で満たされるため、
  # 待たずに buildkit を起動すると setuptool が child_pid を読めずに失敗する。失敗を
  # 重ねると systemd の既定の StartLimit に達して buildkit が起動しなくなるため、ここで待つ。
  waitForContainerdRootless = pkgs.writeShellScriptBin "wait-for-containerd-rootless" ''
    for _ in $(${pkgs.coreutils}/bin/seq 1 60); do
      if [ -r "$XDG_RUNTIME_DIR/containerd-rootless/child_pid" ]; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done
    echo "containerd-rootless の child_pid が現れませんでした" >&2
    exit 1
  '';

  # systemd の path オプションは PATH を丸ごと置き換えるため、スクリプトが呼ぶ
  # バイナリをすべて列挙する必要がある。/run/wrappers は setuid の mount と
  # ケーパビリティ付きの newuidmap、newgidmap を提供する。
  commonPath = [
    "/run/wrappers"
    pkgs.containerd
    pkgs.runc
    pkgs.rootlesskit
    pkgs.slirp4netns
    pkgs.cni-plugins
    pkgs.iptables
    pkgs.iproute2
    pkgs.util-linux
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gnused
  ];
in
{
  # ログインセッションが無くてもユーザーサービスが起動時に立ち上がるようにする。
  users.users.${user}.linger = true;

  systemd.user.services.containerd = {
    description = "containerd (Rootless)";
    wantedBy = [ "default.target" ];
    requires = [ "dbus.socket" ];
    after = [ "dbus.socket" ];
    path = commonPath;
    unitConfig = {
      # StartLimitIntervalSec と StartLimitBurst は Service ではなく Unit セクションの設定である。
      StartLimitIntervalSec = "60s";
      StartLimitBurst = 3;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${rootlessHelpers}/bin/containerd-rootless.sh";
      ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
      TimeoutSec = 0;
      Restart = "always";
      RestartSec = 2;
      LimitNOFILE = "infinity";
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
      TasksMax = "infinity";
      Delegate = true;
      KillMode = "mixed";
    };
  };

  systemd.user.services.buildkit = {
    description = "BuildKit (Rootless)";
    wantedBy = [ "default.target" ];
    requires = [ "containerd.service" ];
    after = [ "containerd.service" ];
    partOf = [ "containerd.service" ];
    # buildkitd は git が無いと警告を出して git ソースを無効化する。
    path = commonPath ++ [ pkgs.git ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${waitForContainerdRootless}/bin/wait-for-containerd-rootless";
      # rootless の nerdctl build に必要な buildkitd は containerd-rootless.sh が作った
      # 名前空間の中で動かす必要があり、setuptool の nsenter サブコマンドが child_pid を
      # 読んで RootlessKit の環境を引き継ぎながら名前空間に入る。
      # --oci-worker-net=bridge が要求する CNI の bridge プラグインは NixOS の既定パス
      # /opt/cni/bin に無いため --oci-cni-binary-dir で明示する。
      # --root を省くと既定の /var/lib/buildkit が RootlessKit の copy-up した tmpfs に
      # 置かれ、containerd を再起動するたびにビルドキャッシュが消える。永続する
      # ~/.local/share/buildkit を指定する。
      ExecStart = "${rootlessHelpers}/bin/containerd-rootless-setuptool.sh nsenter -- ${pkgs.buildkit}/bin/buildkitd --oci-worker-rootless --oci-worker-net=bridge --oci-cni-binary-dir=${pkgs.cni-plugins}/bin --root=${home}/.local/share/buildkit";
      ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
      Restart = "always";
      RestartSec = 2;
      KillMode = "mixed";
    };
  };
}
