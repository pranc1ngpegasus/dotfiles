_: {
  imports = [
    ../base
    ./docker.nix
    ./grok-leader.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519";
  };
}
