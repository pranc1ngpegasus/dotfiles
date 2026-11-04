{
  home.file.".codex/deepseek.config.toml".text = ''
    model = "deepseek-v4.1-flash:1017"
    model_provider = "ollama_cloud"
    web_search = "disabled"

    [model_providers.ollama_cloud]
    name = "Ollama Cloud"
    base_url = "https://ollama.com/v1"
    env_key = "OLLAMA_API_KEY"
    wire_api = "responses"
  '';
}
