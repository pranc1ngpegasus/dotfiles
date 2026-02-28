{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com/" = {
      addKeysToAgent = "yes";
      extraOptions = {
        UseKeychain = "yes";
      };
      identityFile = "~/.ssh/id_ed25519";
    };
  };
}
