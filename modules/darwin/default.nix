{
  imports = [
    ../common.nix
    ./docker.nix
    ./environment.nix
    ./fonts.nix
    ./system-defaults.nix
    ./security.nix
    ./home-manager.nix
    ./llm-agents.nix
    ./neovim-overlay.nix
    ./ollama.nix
  ];
}
