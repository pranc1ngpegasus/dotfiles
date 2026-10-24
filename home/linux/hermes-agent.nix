{
  config,
  lib,
  pkgs,
  ...
}:
let
  envFile = "${config.home.homeDirectory}/.local/share/hermes/env";
  identity = toString (builtins.head config.age.identityPaths);

  # agenix の home-manager モジュールは秘密情報を systemd のユーザーサービスで復号する。
  # home-manager の activation が .env を書く時点ではまだ復号されていないため、ここで
  # 先に env ファイルを作り、environmentFiles の読み込みに間に合わせる。
  envScript = pkgs.writeShellScript "hermes-env" ''
    set -eu

    identity="$1"
    output="$2"
    ollama="$3"
    dashboard="$4"

    if [ ! -r "$identity" ]; then
      echo "hermes-agent: cannot read $identity; the dashboard has no API key or login" >&2
      exit 0
    fi

    ${pkgs.coreutils}/bin/install -d -m 0700 "$(${pkgs.coreutils}/bin/dirname "$output")"
    ${pkgs.coreutils}/bin/install -m 0600 /dev/null "$output"
    (
      umask 077
      printf 'OLLAMA_API_KEY=%s\n' "$(${pkgs.age}/bin/age --decrypt -i "$identity" "$ollama")"
      ${pkgs.age}/bin/age --decrypt -i "$identity" "$dashboard"
    ) > "$output"
  '';
in
{
  services.hermes-agent = {
    # Tailscale Serve が 8443 で受けたリクエストをこの loopback の dashboard へ流す。
    # dashboard.public_url は Host ヘッダの検証と認証ゲートに使われる。
    backend = {
      mode = "dashboard";
      host = "127.0.0.1";
      port = 9119;
    };
    settings.dashboard.public_url = "https://nixos.tail9103a.ts.net:8443";
    environmentFiles = [ envFile ];
  };

  home.activation.hermesEnv = lib.mkIf config.services.hermes-agent.enable (
    lib.hm.dag.entryBefore [ "hermesAgentSetup" ] ''
      $DRY_RUN_CMD ${envScript} ${lib.escapeShellArg identity} ${lib.escapeShellArg envFile} ${lib.escapeShellArg "${../../secrets/ollama-api-key.age}"} ${lib.escapeShellArg "${../../secrets/hermes-dashboard.age}"}
    ''
  );
}
