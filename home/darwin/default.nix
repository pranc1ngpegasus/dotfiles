{ ... }:
{
  imports = [
    ../base
    ./docker.nix
    ./ghostty.nix
    ./nh.nix
    ./secure-enclave-key.nix
  ];

  my = {
    ssh.identityFile = "~/.ssh/id_enclave_key";
    git.signingKey = "~/.ssh/id_enclave_key";
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
