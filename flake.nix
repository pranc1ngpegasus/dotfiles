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

    fish-done = {
      url = "github:franciscolourenco/done";
      flake = false;
    };

    fish-ghq = {
      url = "github:decors/fish-ghq";
      flake = false;
    };

    fish-fzf = {
      url = "github:jethrokuan/fzf";
      flake = false;
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
      darwinConfigurations = {};
      overlays = {};
    };
}
