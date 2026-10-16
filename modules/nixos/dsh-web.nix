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

    # dsh のクライアントはページの origin がループバックのときだけ Host の設定文書を
    # 読む。tailnet の名前で開いた画面ではプロバイダーを設定できないので、デプロイが
    # 宣言した authority (--trusted-host) をループバックと同じ扱いにする。パッチは
    # 入力の改訂に固定されており、改訂が変わると適用に失敗してビルドが止まる。
    patches = [ ./dsh-web-trusted-hosts.patch ];

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
      # 宣言した authority を特権として扱うパッチがまだ効いているかの目印。
      grep -q "__DSH_CONNECTION_TRUSTED_HOSTS__" $out/share/dsh/packages/client/connection/lib/client.js
      runHook postInstallCheck
    '';

    meta.mainProgram = "dsh";
    meta.platforms = [ "x86_64-linux" ];
  });
  # dsh は 0.0.0.0 での待ち受けを安全性のために拒否する (「it would expose remote
  # code execution to the network」)。そのため dsh は 127.0.0.1:3081 で待ち受け、
  # tailnet 側の窓口は nginx が 3080 で担う。tailnet の名前はサービス起動時に
  # tailscaled から解決し、表示 URL と信頼する権限に渡す。
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

  # tailnet から届くのは 3080 だけである。LAN 側のインターフェースは開放しない。
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3080 ];

  # ブラウザーが送った Host をそのまま渡す。dsh が発行する Cookie は URL の
  # authority (ホストとポート) に紐付くため、ポートを落とすと 401 になる。
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

  # tailnet の名前は --trusted-host として宣言するので、パッチによりループバックと
  # 同じ特権で設定文書を読み書きできる。nginx を経由できないときは、同じサービスへ
  # SSH ポート転送で入るループバックの面も使える。詳細は docs/dsh-web.md。
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
