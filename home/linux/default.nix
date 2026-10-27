_: {
  imports = [
    ../base
    ./docker.nix
    ./dsh-web.nix
    ./hermes-agent.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
