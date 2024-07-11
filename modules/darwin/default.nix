{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./system.nix
  ];

  environment = {
    pathsToLink = ["/Applications"];
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
        ];
      })
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel"];
      substituters = outputs.nixConfig.extra-substituters;
      trusted-public-keys = outputs.nixConfig.extra-trusted-public-keys;
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      warn-dirty = false;
    };

    package = pkgs.nix;
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  services = {
    nix-daemon = {
      enable = true;
    };
  };

  time = {
    timeZone = "Asia/Tokyo";
  };
}
