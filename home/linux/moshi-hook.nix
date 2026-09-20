{
  config,
  lib,
  pkgs,
  ...
}:
let
  # moshi-hook は公式が CDN で配布するビルド済みバイナリのみを提供しているため、
  # リリースを固定して取得する。更新するときは version と各 hash を書き換える。
  moshi-hook = pkgs.callPackage (
    {
      lib,
      stdenv,
      fetchurl,
    }:
    let
      version = "0.3.26";

      assets = {
        x86_64-linux = {
          name = "moshi-hook_Linux_x86_64.tar.gz";
          hash = "sha256-AkFhSriCghWYAMr5oKZSMLjpJ+IfAqbTTsws/tx4JVA=";
        };
        aarch64-linux = {
          name = "moshi-hook_Linux_arm64.tar.gz";
          hash = "sha256-0QVwP7BT5q9BbnucqdjOOx+0iEQ1haHF6kX9OSukgRg=";
        };
      };

      asset =
        assets.${stdenv.hostPlatform.system}
          or (throw "moshi-hook: unsupported platform ${stdenv.hostPlatform.system}");
    in
    stdenv.mkDerivation {
      pname = "moshi-hook";
      inherit version;

      src = fetchurl {
        url = "https://cdn.getmoshi.app/hook/v${version}/${asset.name}";
        inherit (asset) hash;
      };

      sourceRoot = ".";

      dontConfigure = true;
      dontBuild = true;

      # 配布物はビルド済みのバイナリなので、strip や patchelf による改変を避ける。
      dontStrip = true;
      dontPatchELF = true;

      installPhase = ''
        runHook preInstall

        install -Dm755 moshi-hook $out/bin/moshi-hook
        ln -s moshi-hook $out/bin/moshi

        runHook postInstall
      '';

      meta = {
        description = "Daemon and CLI that connects a host to Moshi";
        longDescription = ''
          moshi-hook は AI エージェントのフックを導入し、Moshi クライアントが使う
          ローカルゲートウェイとソケットブリッジを提供する。承認とセッション更新の
          ために Moshi への WebSocket 接続も維持する。

          公式は CDN でビルド済みバイナリを配布しているため、このパッケージは
          そのリリースを固定してストアへ配置する。moshi-hook 自身の自己更新は
          ストアのパスを書き換えられないため、更新はこのパッケージの version と
          hash を書き換えて行う。
        '';
        homepage = "https://getmoshi.app/";
        license = lib.licenses.unfree;
        mainProgram = "moshi-hook";
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = builtins.attrNames assets;
      };
    }
  ) { };
in
{
  home.packages = [ moshi-hook ];

  # `moshi-hook service install` は systemd ユニットを命令的に書き込むため、
  # ここで宣言的に定義して世代管理の対象にする。
  systemd.user.services.moshi-hook = {
    Unit = {
      Description = "Moshi hook daemon";
      After = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${lib.getExe moshi-hook} serve";
      Restart = "on-failure";
      RestartSec = 5;
      # デーモンは PATH から tmux と各エージェントの CLI を解決するため、
      # moshi-hook が生成するユニットと同様に PATH を明示する。
      Environment = [
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin"
      ];
      WorkingDirectory = "%h";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
