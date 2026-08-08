{
  inputs,
  lib,
  ...
}:
let
  src = "${inputs.fireconnect}/packages/setup-cli";
  packageJson = lib.importJSON "${src}/package.json";
in
{
  perSystem = { pkgs, ... }: {
    packages.fireconnect = pkgs.buildNpmPackage {
      pname = "fireconnect";
      inherit (packageJson) version;
      inherit src;

      npmDepsHash = "sha256-PD3W8nqQTfx18EPF/fEBxoPdigwUaWtWxFs3vuOLrak=";

      dontNpmBuild = true;

      meta = {
        description = "Use Fireworks AI models in Claude Code, OpenCode, Codex, Pi, Cursor, VS Code, and Deep Agents";
        homepage = "https://github.com/fw-ai/fireconnect";
        license = lib.licenses.asl20;
        platforms = pkgs.nodejs.meta.platforms;
      };
    };
  };
}
