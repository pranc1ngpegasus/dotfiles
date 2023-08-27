{
  description = "Pranc1ngPegasus's system configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
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
  };

  outputs = {...}: {
  };
}
