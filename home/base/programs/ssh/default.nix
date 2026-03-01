{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com" = {
      addKeysToAgent = "yes";
      extraOptions = {
        UseKeychain = "yes";
      };
      hostname = "github.com";
      identitiesOnly = true;
      identityFile = "~/.ssh/id_ed25519_auth";
      user = "git";
    };
  };
}
