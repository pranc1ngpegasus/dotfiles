{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  grok = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok;
in
{
  xdg.configFile."rustxng/settings.toml".text = ''
    [server]
    bind_address = "127.0.0.1"
    port = 8888

    [search]
    # mcp-searxng は SearXNG の JSON API を読むため、json を有効にする。
    formats = ["html", "json"]
  '';

  # Grok は managed_config.toml の MCP サーバーをセッションへ読み込まないため、
  # ユーザー設定へ登録する。grok mcp add は rustxng の項目だけを更新する。
  home.activation.rustxngMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run env GROK_HOME="${config.home.homeDirectory}/.grok" ${lib.getExe grok} mcp add rustxng \
      -e SEARXNG_URL=http://127.0.0.1:8888 \
      -- ${lib.getExe pkgs.mcp-searxng}
  '';
}
