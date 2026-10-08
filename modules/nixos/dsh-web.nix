{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (pkgs)
    stdenv
    fetchurl
    makeWrapper
    writeShellScript
    pnpm_11
    fetchPnpmDeps
    nodejs_22
    ;

  inherit (inputs) deepseek-harness;

  primaryUser = config.my.primaryUser;
  userHome = config.users.users.${primaryUser}.home;
  userUid = config.users.users.${primaryUser}.uid;

  # dsh 0.2.x の node-addon-require-builtin は nixpkgs の Node ビルドでは動かない。
  # 公式バイナリをそのまま使い、autoPatchelfHook で NixOS の glibc/libstdc++ を解決する。
  # アドオンが V8 のプライベートシンボルをバイナリから探すため、strip してはいけない。
  nodejs-official = stdenv.mkDerivation (finalAttrs: {
    pname = "nodejs-official";
    version = "22.23.3";
    src = fetchurl {
      url = "https://nodejs.org/dist/v${finalAttrs.version}/node-v${finalAttrs.version}-linux-x64.tar.xz";
      hash = "sha256-30UK+JJhEV75+eODDD7rLMkhO2PHILGvYjy13L4uAt4=";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      runHook postInstall
    '';
    meta.mainProgram = "node";
    meta.platforms = [ "x86_64-linux" ];
  });

  dsh-shiguredo = stdenv.mkDerivation (finalAttrs: {
    pname = "dsh-shiguredo";
    version = "0.2.1-alpha.1";
    src = deepseek-harness;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_11;
      fetcherVersion = 4;
      hash = "sha256-/RvayNtK+6hJXOiRO17JZQS7lGFnPaQJQkD/Z8bUIHQ=";
    };

    nativeBuildInputs = [
      nodejs_22
      pnpm_11
      pkgs.pnpmConfigHook
      makeWrapper
    ];

    # サンドボックス内に .git がないため、git rev-parse HEAD の代わりにコミットハッシュを渡す。
    env.DSH_CLIENT_COMMIT_HASH = deepseek-harness.rev;

    # pnpmConfigHook は postConfigureHook として $HOME に pushd するので、
    # 書き込み可能な HOME を事前に用意する。
    preConfigure = "export HOME=$(mktemp -d)";

    buildPhase = ''
      runHook preBuild
      pnpm rebuild esbuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/dsh
      cp -a . $out/share/dsh/
      makeWrapper ${lib.getExe nodejs-official} $out/bin/dsh \
        --argv0 dsh \
        --add-flags "--expose-internals" \
        --add-flags "$out/share/dsh/apps/cli/lib/bin.js"
      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      export DSH_HOME=$(mktemp -d)
      $out/bin/dsh --version
      $out/bin/dsh web --help
      runHook postInstallCheck
    '';

    meta.mainProgram = "dsh";
    meta.platforms = [ "x86_64-linux" ];
  });

  # tailnet のアドレスはコントロールプレーンが決めるため、サービス起動時に tailscaled から
  # 解決する。dsh は 0.0.0.0 を受け付けないので 127.0.0.1:3081 で待ち受け、nginx が tailnet
  # 側の 3080 から中継する。
  launch = writeShellScript "dsh-web-launch" ''
    set -eu
    tailscale=${pkgs.tailscale}/bin/tailscale
    jq=${pkgs.jq}/bin/jq
    ip="$("$tailscale" ip --4)"
    fqdn="$("$tailscale" status --json | "$jq" -r '.Self.DNSName | rtrimstr(".")')"
    exec ${lib.getExe dsh-shiguredo} web \
      --no-open \
      --host 127.0.0.1 \
      --port 3081 \
      --public-url "http://$fqdn:3080/" \
      --trusted-host "$fqdn" \
      --trusted-host "$ip"
  '';
in
{
  environment.systemPackages = [ dsh-shiguredo ];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3080 ];

  services.nginx = {
    enable = true;
    enableReload = true;
    virtualHosts."dsh" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 3080;
        }
        {
          addr = "[::]";
          port = 3080;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:3081";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host:$server_port;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
          proxy_buffering off;
        '';
      };
    };
  };

  systemd.services.dsh-web = {
    description = "DeepSeek Harness Web UI (shiguredo fork) on the tailnet";
    wantedBy = [ "multi-user.target" ];
    after = [
      "tailscaled.service"
      "network-online.target"
    ];
    wants = [
      "tailscaled.service"
      "network-online.target"
    ];
    serviceConfig = {
      User = primaryUser;
      WorkingDirectory = userHome;
      Environment = [
        "HOME=${userHome}"
        "PATH=/etc/profiles/per-user/${primaryUser}/bin:/run/current-system/sw/bin:/run/wrappers/bin"
        "DOCKER_HOST=unix:///run/user/${toString userUid}/docker.sock"
      ];
      ExecStart = launch;
      Restart = "always";
      RestartSec = 5;
    };
  };
}
