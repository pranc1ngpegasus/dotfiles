{ inputs, ... }:
{
  nixpkgs.overlays = [
    (_final: prev: {
      rustxng = prev.rustPlatform.buildRustPackage {
        pname = "rustxng";
        version = "0.26.0";

        src = inputs.rustxng;

        cargoHash = "sha256-StbnHCm2uxYph141nQ/gZ3XnrTZSIDh7haquazc8q1U=";

        meta = {
          description = "Self-hosted, SearXNG-compatible web search API";
          homepage = "https://github.com/sahenjp/RustXNG";
          license = prev.lib.licenses.agpl3Plus;
          mainProgram = "rustxng";
          platforms = prev.lib.platforms.unix;
        };
      };
    })
  ];
}
