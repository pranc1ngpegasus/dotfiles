{ inputs, ... }:
{
  imports = [
    ../base
    ./moshi-hook.nix
    inputs.nix-index-database.homeModules.nix-index
  ];

  my = {
    git.signingKey = "~/.ssh/id_ed25519_signing";
  };

  home = {
    stateVersion = "26.11";
  };
}
