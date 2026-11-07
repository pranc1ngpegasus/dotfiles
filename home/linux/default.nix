_: {
  imports = [
    ../base
    ./docker.nix
    ./obsidian-headless.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
