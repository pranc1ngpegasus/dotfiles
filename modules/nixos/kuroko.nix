# kuroko を NixOS のサービスとして動かす。上流の flake が NixOS モジュールを
# 公開しているので、ここではそのオプションに値を入れるだけでよい。
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  grok = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok;

  # kuroko は課題の本文を子プロセスの標準入力へ書き、終了コードだけで成否を
  # 判定する。grok はモデル定義を HOME の config.toml から読むため、サービスを
  # 主要ユーザーで動かして同じ設定を使う。API キーだけは kuroko の環境に置かず、
  # credential から子プロセスへ渡す。
  agent = pkgs.writeShellScript "kuroko-agent" ''
    set -euo pipefail
    export OLLAMA_API_KEY="$(< "''${CREDENTIALS_DIRECTORY}/ollama-api-key")"
    # 人がいない実行では質問が返らない。ユーザーの config.toml は質問の
    # タイムアウトを無効にしているので、サービス側でだけ上限を設ける。
    export GROK_ASK_USER_QUESTION_TIMEOUT_ENABLED=1
    export GROK_ASK_USER_QUESTION_TIMEOUT_SECS=300
    # エージェントのツール呼び出しはこの PATH で git や gh を探す。systemd が
    # 既定で入れる coreutils だけでは、リポジトリの操作ができない。
    export PATH="/etc/profiles/per-user/${config.my.primaryUser}/bin:/run/current-system/sw/bin"
    exec ${lib.getExe grok} \
      --always-approve \
      --output-format plain \
      --prompt-file /dev/stdin
  '';
in
{
  imports = [
    inputs.kuroko.nixosModules.default
  ];

  services.kuroko = {
    enable = true;

    # エージェントは主要ユーザーのリポジトリを編集し、その gh や git の認証を
    # 使うため、サービスもこのユーザーで動かす。
    user = config.my.primaryUser;
    group = "users";

    # 署名鍵は /var/lib ではなく agenix が復号したファイルから読む。
    environmentFile = config.age.secrets.kuroko-env.path;

    settings = {
      transport.stdio.command = toString agent;

      trigger.any_delegate = true;

      prompt.template = ''
        Resolve this Linear issue in the workspace.

        Issue {identifier}: {title}

        {description}

        {url}
      '';
    };

    # stdio のエージェントはこのディレクトリで動く。
    workingDirectory = "/home/${config.my.primaryUser}/ghq/github.com/mokmok-dev";

    extraServiceConfig.LoadCredential = "ollama-api-key:${config.age.secrets.ollama-api-key.path}";
  };

  # 上流のモジュールはサービス用のユーザーをシステムユーザーとして既定化する。
  # 主要ユーザーは通常ユーザーとして hosts/ で宣言済みなので、その既定を打ち消す。
  users.users.${config.my.primaryUser}.isSystemUser = lib.mkForce false;
}
