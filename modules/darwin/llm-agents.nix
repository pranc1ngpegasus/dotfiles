{ inputs, pkgs, ... }:
let
  codexCli = pkgs.symlinkJoin {
    name = "codex-cli";
    paths = [ inputs.llm-agents.packages.${pkgs.system}.codex ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/codex" \
        --run 'if [[ "$1" == "app" ]]; then
          unset CODEX_HOME
        else
          export CODEX_HOME="$HOME/.codex-cli"
          mkdir -p "$CODEX_HOME"
        fi'
    '';
  };
in
{
  imports = [
    inputs.nix-index-database.darwinModules.nix-index
  ];

  environment = {
    systemPackages = [
      inputs.codebase-memory-mcp.packages.${pkgs.system}.default
      codexCli
      inputs.llm-agents.packages.${pkgs.system}.opencode
      inputs.llm-agents.packages.${pkgs.system}.grok
    ];
  };
}
