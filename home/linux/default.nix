_: {
  imports = [
    ../base
    ./docker.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
