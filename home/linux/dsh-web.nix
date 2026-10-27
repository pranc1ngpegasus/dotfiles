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

  # モデルの設定は Web UI の Models ページがプロファイルのパッチ
  # (~/.dsh/profiles/web/cordis.patch.yml) に書く。パッチは対象の行の config を
  # 丸ごと置き換え、--patch はプロファイルより後ろに重なるため、--patch で同じ行を
  # 渡すと UI の保存が「overridden by a command-line overlay」で弾かれる。
  # そこで既定の経路は、この行がまだ無いときだけ同じファイルへ書き込む初期値として
  # 扱い、以後の変更は UI に任せる。
  providerSeed = pkgs.writeText "dsh-ollama-cloud-provider.yml" ''
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
  '';

  defaultModelSeed = pkgs.writeText "dsh-ollama-cloud-default-model.yml" ''
    - id: agent-default-model
      config:
        provider: ollama-cloud
        model: deepseek-v4.1-flash
  '';

  seedProfile = pkgs.writeShellScript "dsh-seed-profile" ''
    set -eu

    home="''${DSH_HOME:-$HOME/.dsh}"
    profile="$home/profiles/web"
    patch="$profile/cordis.patch.yml"

    # プロファイルがまだ無い初回は、dsh 自身にテンプレートから作らせる。
    # --dump-config はアプリを起動せず、プロファイルの初期化だけを行う。
    if [ ! -f "$profile/package.json" ]; then
      ${lib.getExe dsh} --profile web --dump-config > /dev/null
    fi

    # 行がまだ無いときだけ差し込む。UI で編集した行には触らない。
    seed_row() {
      id="$1"
      source="$2"

      if grep -qE "^[[:space:]]*-[[:space:]]*id:[[:space:]]*[\"']?$id[\"']?[[:space:]]*$" "$patch"; then
        return 0
      fi

      tmp="$(mktemp "$profile/.cordis.patch.XXXXXX")"
      if [ "$(grep -vE '^[[:space:]]*(#|$)' "$patch" || true)" = "[]" ]; then
        # 空配列だけのファイルは、ヘッダのコメントを残して行を差し替える。
        { grep -E '^[[:space:]]*(#|$)' "$patch" || true; cat "$source"; } > "$tmp"
      else
        { cat "$source"; cat "$patch"; } > "$tmp"
      fi
      chmod 600 "$tmp"
      mv "$tmp" "$patch"
    }

    seed_row llm-pi-ai ${providerSeed}
    seed_row agent-default-model ${defaultModelSeed}
  '';

  start = pkgs.writeShellScript "dsh-web" ''
    set -eu

    # API キーは agenix が復号して XDG_RUNTIME_DIR に置く。dsh は apiKeyEnv が
    # 指す環境変数をリクエストのたびに読むため、起動時に環境へ読み込む。
    OLLAMA_API_KEY="$(cat ${config.age.secrets.ollama-api-key.path})"
    export OLLAMA_API_KEY

    exec ${lib.getExe dsh} web \
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
      ExecStartPre = seedProfile;
      ExecStart = start;
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
