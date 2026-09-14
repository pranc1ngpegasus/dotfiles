_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/id_enclave_key";
      };
      "*.tt.ts.net" = {
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/id_enclave_key";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };
      "100.*" = {
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/id_enclave_key";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };
    };
  };
}
