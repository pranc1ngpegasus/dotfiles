{
  description = "Pranc1ngPegasus's system configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    neovim = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deno = {
      url = "https://github.com/denoland/deno";
      inputs.nixpkgs.follows = "nixpkgs";
      flake = false;
    };

    zsh-ghq-fzf = {
      url = "github:Pranc1ngPegasus/zsh-ghq-fzf";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    darwin,
    neovim,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages = {
        inherit (inputs.devenv.packages.${system}) devenv;
        neovim = inputs.neovim.packages.${system}.default;
        bunV1 = pkgs.bun.overrideAttrs (final: prev:
          with pkgs;
            prev
            // rec {
              version = "1.0.11";
              src = passthru.sources.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
              passthru =
                prev.passthru
                // {
                  sources =
                    prev.passthru.sources
                    // {
                      "aarch64-darwin" = fetchurl {
                        url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
                        sha256 = "yZp/AFlOVRtZ60865utrtVv0zlerwFMhpqBh26WnfL8=";
                      };
                      "x86_64-darwin" = fetchurl {
                        url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-x64.zip";
                        sha256 = "1brxbrc7dsqazmqzwlb8ym9rczr67lfk67sqnp3z66l4pwc3f0gp";
                      };
                      "aarch64-linux" = fetchurl {
                        url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
                        sha256 = "16xkf7fcfjrmzayb4crb7l6ai4jzshihi9924b70m8lid07hmlzz";
                      };
                      "x86_64-linux" = fetchurl {
                        url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
                        sha256 = "0b0wlxh2nmal1izw8hf239cg68ngnd0if4sqg3k7n2sdr0cpwgx5";
                      };
                    };
                };
            });
      };
    })
    // {
      nixConfig = {
        extra-substituers = [
          "https://nix-community.cachix.org"
          "https://devenv.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
      };
      homeManagerModules = [];
      nixosModules = [];
      nixosConfigurations = {};
      darwinConfigurations = {
        "MacBookAirM2" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./darwin/hosts/MacBookAirM2
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
        "adminnoMacBook-Pro" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./darwin/hosts/adminnoMacBook-Pro
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };
      overlays = {};
    };
}
