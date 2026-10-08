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
in
{
  environment.systemPackages = [ dsh-shiguredo ];

  # dsh のブラウザー UI は、ページの origin がループバックのときだけ Host の設定文書を
  # 読む。tailnet の名前や IP で開くと設定はページ内のメモリに閉じ、Settings の Models が
  # "settings are unavailable in this browser" を返して API キーも設定できなくなる。
  # そのためサービスは既定の 127.0.0.1:3080 で待ち受け、Mac 側の SSH ポート転送で届かせる。
  systemd.services.dsh-web = {
    description = "DeepSeek Harness Web UI (shiguredo fork)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = primaryUser;
      WorkingDirectory = userHome;
      Environment = [
        "HOME=${userHome}"
        "PATH=/etc/profiles/per-user/${primaryUser}/bin:/run/current-system/sw/bin:/run/wrappers/bin"
        "DOCKER_HOST=unix:///run/user/${toString userUid}/docker.sock"
      ];
      ExecStart = "${lib.getExe dsh-shiguredo} web --no-open";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
