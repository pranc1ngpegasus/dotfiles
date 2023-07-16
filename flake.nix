{
  description = "My system configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-22.11";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv/latest";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    darwin,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in
    flake-utils.lib.eachDefaultSystem
    (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages = {
        inherit (inputs.devenv.packages.${system}) devenv;
      };

      homeConfigurations = {
        pranc1ngpegasus = let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            extraSpecialArgs = {
              inherit inputs outputs;
            };

            modules = [
              ./home/users/pranc1ngpegasus/home.nix
            ];
          };
        temma.fukaya = let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            extraSpecialArgs = {
              inherit inputs outputs;
            };

            modules = [
              ./home/users/temma.fukaya/home.nix
            ];
          };
      };
    })
    // {
      darwinConfigurations = {
        "FVFHQ1JRQ05N" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          modules = [
            ./darwin/hosts/FVFHQ1JRQ05N
          ];

          specialArgs = {
            inherit inputs outputs;
          };
        };
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

      nixosConfigurations = {
        "dinii" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./nixos/hosts/dinii
          ];

          specialArgs = {
            inherit inputs outputs;
          };
        };
      };

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
    };
}
