_: {
  imports = [
    ../base
    ./moshi-hook.nix
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };
}
