_: {
  imports = [
    ../base
    ./nerdctl.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
