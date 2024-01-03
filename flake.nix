{
  description = "Pranc1ngPegasus's system configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
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
    flake-utils.lib.eachDefaultSystem (system: {
      packages = {
        inherit (inputs.devenv.packages.${system}) devenv;
        neovim = inputs.neovim.packages.${system}.default;
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
