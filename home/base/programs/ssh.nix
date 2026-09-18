{ config, lib, ... }:
let
  identityFile = lib.optionalAttrs (config.my.ssh.identityFile != null) {
    IdentityFile = config.my.ssh.identityFile;
  };
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentitiesOnly = true;
      }
      // identityFile;
      "*.tt.ts.net" = {
        IdentitiesOnly = true;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        "#!! UdpMode" = "KCP";
        "#!! TsshdPort" = "61001-61999";
      }
      // identityFile;
      "100.*" = {
        IdentitiesOnly = true;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      }
      // identityFile;
    };
  };
}
