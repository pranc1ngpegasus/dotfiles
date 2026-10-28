{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  opencode2 = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;

  # service モードのサーバーはパスワードを環境変数ではなく、この設定ファイルから
  # 読む。cors や env など利用者が設定したキーを消さないよう、既存の内容を読んで
  # から 3 つのキーだけを上書きする。
  start = pkgs.writeShellScript "opencode" ''
    set -eu

    service_dir="${config.xdg.configHome}/opencode"
    service_file="$service_dir/service.json"
    password="$(cat ${config.age.secrets.opencode-web-password.path})"
    mkdir -p "$service_dir"

    tmp="$(mktemp "$service_dir/.service.json.XXXXXX")"
    if ! ${pkgs.jq}/bin/jq \
      --arg password "$password" \
      '. + {hostname: "127.0.0.1", port: 3080, password: $password}' \
      "$service_file" > "$tmp" 2>/dev/null; then
      ${pkgs.jq}/bin/jq -n \
        --arg password "$password" \
        '{hostname: "127.0.0.1", port: 3080, password: $password}' > "$tmp"
    fi
    chmod 600 "$tmp"
    mv "$tmp" "$service_file"

    # モデルの一覧は models.dev から取得するため、プロバイダの認証は環境変数で
    # 渡す。systemd のユーザーサービスは対話シェルの環境を引き継がない。
    OLLAMA_API_KEY="$(cat ${config.age.secrets.ollama-api-key.path})"
    export OLLAMA_API_KEY

    exec ${lib.getExe opencode2} serve \
      --service \
      --hostname 127.0.0.1 \
      --port 3080 \
      --print-logs
  '';
in
{
  age.secrets.opencode-web-password.file = ../../secrets/opencode-web-password.age;

  systemd.user.services.opencode = {
    Unit.Description = "OpenCode server and web UI";
    Service = {
      ExecStart = start;
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
