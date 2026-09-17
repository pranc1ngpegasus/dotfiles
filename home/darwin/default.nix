{ inputs, ... }:
{
  imports = [
    ../base
    inputs.nix-index-database.homeModules.nix-index
    ./ghostty.nix
    ./nh.nix
    ./secure-enclave-key.nix
  ];

  my = {
    ssh.identityFile = "~/.ssh/id_enclave_key";
    git.signingKey = "~/.ssh/id_enclave_key";
  };

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
