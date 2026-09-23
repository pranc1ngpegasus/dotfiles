{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  dsh = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh;

  # dsh の Web UI が待ち受けるポート。modules/nixos/tailscale.nix の
  # tailscale-serve が同じポートへ転送するため、変更するときは両方を揃える。
  port = 3080;

  # agenix (home-manager モジュール) は秘密を $XDG_RUNTIME_DIR/agenix/<name> へ復号する。
  # オプションの path は $XDG_RUNTIME_DIR を展開する前提の文字列なので、名前だけ取り出す。
  ollamaApiKeyName = baseNameOf config.age.secrets."ollama-api-key".path;

  # Models ページが書き込むのと同じプロファイルパッチをここから生成する。ブラウザ
  # からの設定は loopback に限られるため、tailnet 経由でも使えるプロバイダと既定
  # モデルはこのファイルで定義する。API キーは apiKeyEnv の参照に任せ、値は
  # agenix の秘密からサービスへ渡す。
  profilePatch = pkgs.writeText "cordis-patch.yml" ''
    - id: llm-pi-ai
      config:
        providers:
          ollama:
            displayName: Ollama Cloud
            apiKeyEnv: OLLAMA_API_KEY
            api: openai-completions
            baseURL: https://ollama.com/v1
            models:
              - id: deepseek-v4.1-flash
                name: DeepSeek V4.1 Flash
                contextWindow: 1310720

    - id: agent-default-model
      config:
        provider: ollama
        model: deepseek-v4.1-flash
  '';

  # dsh web のブラウザ信頼フェンスは、Host ヘッダが loopback か --trusted-host の
  # authority と一致することを要求する。Tailscale Serve は Host ヘッダをそのまま
  # 転送するため、tailnet から届いたリクエストはこのフェンスで 403 になる。そこで
  # 起動時に tailscaled から MagicDNS 名を取り出し、--trusted-host として渡す。
  dshWeb = pkgs.writeShellApplication {
    name = "dsh-web";

    runtimeInputs = [
      dsh
      pkgs.coreutils
      pkgs.jq
      osConfig.services.tailscale.package
    ];

    text = ''
      # tailscaled が起動する前は MagicDNS 名を取得できないため、取得できるまで待つ。
      dns_name=""
      for _ in {1..30}; do
        dns_name="$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName // empty' || true)"
        if [[ -n "$dns_name" ]]; then
          break
        fi
        sleep 2
      done

      if [[ -z "$dns_name" ]]; then
        echo "dsh-web: Tailscale の MagicDNS 名を取得できませんでした" >&2
        exit 1
      fi

      # プロバイダの API キーは設定ファイルに書かず、agenix が復号したファイルから
      # 環境変数として渡す (プロファイルパッチの apiKeyEnv が参照する)。秘密の path は
      # $XDG_RUNTIME_DIR をシェルで展開する前提の文字列で、systemd の Environment= では
      # 展開されないため、ここで実行時に組み立てる。復号は agenix.service が行うので、
      # 起動順の競合に備えてファイルを待つ。
      ollama_key_file="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/agenix/${ollamaApiKeyName}"
      for _ in {1..30}; do
        if [[ -r "$ollama_key_file" ]]; then
          break
        fi
        sleep 2
      done
      if [[ -r "$ollama_key_file" ]]; then
        OLLAMA_API_KEY="$(< "$ollama_key_file")"
        export OLLAMA_API_KEY
      else
        echo "dsh-web: API キーを読めませんでした ($ollama_key_file)。agenix の復号が済んでいるか確認する" >&2
      fi

      # 公開先の URL を journal に残しておくと、dsh が出力する loopback の URL に
      # トークンを足して tailnet 側の URL を組み立てやすい。
      echo "dsh-web: https://''${dns_name%.}/ で tailnet へ公開する" >&2

      exec dsh web \
        --host 127.0.0.1 \
        --port ${toString port} \
        --no-open \
        --trusted-host "''${dns_name%.}"
    '';
  };
in
{
  home.packages = [
    dsh
  ];

  # dsh 自身もこのファイルを書き換える (Models ページの保存や設定のホットリロード)。
  # 書き換えるとストアへの symlink は実ファイルに置き換わり、以降は Nix 管理から外れる。
  home.file.".dsh/profiles/web/cordis.patch.yml".source = profilePatch;

  # ブラウザのセッションは起動トークン付きの URL を一度開いて作る。トークンは
  # プロセスの起動ごとに変わるため、現在の URL を組み立てる関数を用意する。1 行目が
  # tailnet 用、2 行目が SSH ポートフォワードで loopback として開くとき用である。
  programs.bash.initExtra = ''
    dsh-web-url() {
      local name token
      name="$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName // empty' | sed 's/\.$//')"
      token="$(journalctl --user -u dsh-web -o cat --no-pager 2>/dev/null | grep -o 'token=[A-Za-z0-9_-]*' | tail -1 | cut -d= -f2)"
      if [[ -z "$name" || -z "$token" ]]; then
        printf 'dsh-web-url: Tailscale の MagicDNS 名かトークンを取得できませんでした\n' >&2
        return 1
      fi
      printf 'https://%s/?token=%s\n' "$name" "$token"
      printf 'http://127.0.0.1:${toString port}/?token=%s\n' "$token"
    }
  '';

  systemd.user.services.dsh-web = {
    Unit = {
      Description = "DeepSeek Harness web UI";
      # API キーは agenix.service が復号したファイルから読むため、先に走らせる。
      After = [
        "agenix.service"
        "network-online.target"
      ];
      Wants = [ "agenix.service" ];
    };

    Service = {
      ExecStart = lib.getExe dshWeb;
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "%h";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
