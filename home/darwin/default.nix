{ inputs, ... }:
{
  imports = [
    ../base
    inputs.nix-index-database.homeModules.nix-index
    ./agenix.nix
    ./ghostty.nix
    ./secure-enclave-key.nix
  ];

  home = {
    stateVersion = "26.11";
  };

  manual = {
    manpages = {
      enable = false;
    };
  };

  targets = {
    darwin = {
      copyApps.enable = false;
      linkApps.enable = true;
    };
  };
}
