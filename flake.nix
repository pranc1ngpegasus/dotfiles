{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "nix-darwin";
        home-manager.follows = "home-manager";
      };
    };

    neovim = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    codex-gateway = {
      url = "github:pranc1ngpegasus/codex-gateway";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codebase-memory-mcp = {
      url = "github:DeusData/codebase-memory-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.git-hooks.flakeModule
      ];

      systems = [ "aarch64-darwin" ];

      flake = {
        darwinConfigurations = {
          M4MacBookAir = inputs.nix-darwin.lib.darwinSystem {
            modules = [
              ./hosts/M4MacBookAir.nix
              ./modules/darwin
            ];
            specialArgs = { inherit inputs; };
          };
        };
      };

      perSystem = { config, pkgs, ... }: {
        devShells.default = pkgs.mkShellNoCC {
          inputsFrom = [ config.pre-commit.devShell ];
        };

        formatter = pkgs.nixfmt-tree;

        pre-commit.settings = {
          hooks = {
            actionlint.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            statix.excludes = [
              ".direnv"
            ];
          };
          package = pkgs.prek;
        };
      };
    };
}
