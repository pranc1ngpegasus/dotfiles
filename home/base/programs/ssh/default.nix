{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      AddKeysToAgent = "yes";
      HostName = "github.com";
      IdentitiesOnly = true;
      IdentityFile = "~/.ssh/id_ed25519_auth";
      UseKeychain = "yes";
      User = "git";
    };
  };
}
