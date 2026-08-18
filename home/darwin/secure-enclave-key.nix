{ inputs, ... }:
{
  imports = [
    inputs.nix-secure-enclave-key.homeManagerModules.default
  ];

  programs.nix-secure-enclave-key = {
    enable = true;

    identities = {
      git-signing = {
        keyFile = "~/.ssh/id_enclave_key";
        protection = "none";
        autoEnsure = true;
      };
    };

    signingIdentity = "git-signing";
    signByDefault = true;
  };
}
