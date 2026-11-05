{ inputs, ... }:
{
  nixpkgs.overlays = [
    (_final: prev: {
      rustxng = prev.rustPlatform.buildRustPackage {
        pname = "rustxng";
        version = (prev.lib.importTOML (inputs.rustxng + "/Cargo.toml")).package.version;

        src = inputs.rustxng;

        cargoHash = "sha256-THcEYTCqb22jv062cXAvIMGGcGcEbyPP+O1WWxxOoCc=";

        # PDF の読み取りは実行時に PATH の pdftotext を探すため、Poppler を同梱する。
        nativeBuildInputs = [
          prev.makeWrapper
          prev.poppler-utils
        ];

        postInstall = ''
          wrapProgram $out/bin/rustxng \
            --prefix PATH : ${prev.lib.makeBinPath [ prev.poppler-utils ]}
        '';

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
