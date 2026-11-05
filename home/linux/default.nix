_: {
  imports = [
    ../base
    ./docker.nix
    ./dsh-web.nix
    ./obsidian-headless.nix
    ./rustxng.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
