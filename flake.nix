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
        neovim = inputs.neovim.packages.${system}.default;
      };
    })
    // {
      nixConfig = {
        extra-substituters = [
          "https://nix-community.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
      homeManagerModules = [];
      nixosModules = {};
      nixosConfigurations = {};
      darwinConfigurations = {
        "MacBookAirM2" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/MacBookAirM2
            home-manager.darwinModules.home-manager
            {
              home-manager.users.pranc1ngpegasus = import ./home/darwin;
            }
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
        "MacBookProM2Pro" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/MacBookProM2Pro
            home-manager.darwinModules.home-manager
            {
              home-manager.users."temma.fukaya" = import ./home/darwin;
            }
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };
    };
}
