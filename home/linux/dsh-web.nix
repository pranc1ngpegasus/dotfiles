{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  dsh = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh;

  # Tailscale Serve が tailnet の HTTPS (443) で受けたリクエストを、この loopback
  # のリスナーへ流す。ブラウザは Host ヘッダに tailnet の名前を載せるため、
  # trusted-host に同じ authority を登録しないと /api が 403 で拒否される。
  # public-url は起動時に journal へ出す URL にだけ効き、信頼の判定は変えない。
  publicUrl = "https://nixos.tail9103a.ts.net";

  # dsh はモデルの接続先をプロファイルのパッチとして受け取る。このホストの他の
  # エージェントと同じく Ollama Cloud の OpenAI 互換エンドポイントを既定の経路に
  # する。--patch はプロファイル層より後ろに適用されるので、対話で起動する dsh が
  # 持つ自分の設定を書き換えずに、サービス側へだけ差し込める。
  providerPatch = pkgs.writeText "dsh-ollama-cloud.yml" ''
    - id: llm-pi-ai
      config:
        providers:
          ollama-cloud:
            displayName: Ollama Cloud
            api: openai-completions
            baseURL: https://ollama.com/v1
            apiKeyEnv: OLLAMA_API_KEY
            models:
              - id: deepseek-v4.1-flash
    - id: agent-default-model
      config:
        provider: ollama-cloud
        model: deepseek-v4.1-flash
  '';

  start = pkgs.writeShellScript "dsh-web" ''
    set -eu

    # API キーは agenix が復号して XDG_RUNTIME_DIR に置く。dsh は apiKeyEnv が
    # 指す環境変数をリクエストのたびに読むため、起動時に環境へ読み込む。
    OLLAMA_API_KEY="$(cat ${config.age.secrets.ollama-api-key.path})"
    export OLLAMA_API_KEY

    # --patch は dsh 本体側のフラグで、アプリのフラグより先に置く必要がある。
    # 後に置くと web アプリの引数として渡り、未知のフラグとして拒否される。
    exec ${lib.getExe dsh} web \
      --patch ${providerPatch} \
      --host 127.0.0.1 \
      --port 3080 \
      --no-open \
      --public-url ${publicUrl} \
      --trusted-host nixos.tail9103a.ts.net
  '';
in
{
  systemd.user.services.dsh-web = {
    Unit = {
      Description = "DeepSeek Harness web UI";
      # 秘密情報を復号するサービスより後に起動する。復号が終わる前はキーが
      # 読めずに失敗するが、再起動で復旧する。
      after = [ "agenix.service" ];
    };
    Service = {
      ExecStart = start;
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
