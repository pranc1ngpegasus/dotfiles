_: {
  imports = [
    ../base
    ./docker.nix
    ./opencode.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
