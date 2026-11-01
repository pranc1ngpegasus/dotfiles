_: {
  imports = [
    ../base
    ./docker.nix
    ./obsidian-headless.nix
    ./opencode.nix
    ./rustxng.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
