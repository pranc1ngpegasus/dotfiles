_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      HostName = "github.com";
      User = "git";
      IdentitiesOnly = true;
      IdentityFile = "~/.ssh/id_enclave_key";
    };
  };
}
