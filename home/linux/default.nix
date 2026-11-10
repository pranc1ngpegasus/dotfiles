_: {
  imports = [
    ../base
    ./docker.nix
    ./grok-leader.nix
    ./obsidian-headless.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
