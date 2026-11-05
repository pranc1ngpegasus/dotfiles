_: {
  imports = [
    ../base
    ./codex.nix
    ./docker.nix
    ./obsidian-headless.nix
    ./rustxng.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
