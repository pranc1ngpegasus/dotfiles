{ inputs, ... }:
{
  imports = [
    inputs.quash.homeManagerModules.default
  ];

  programs.quash = {
    enable = true;
    hosts."nixos.tail9103a.ts.net" = {
      remote = "100.75.236.9:4433";
      sshTarget = "pranc1ngpegasus@nixos.tail9103a.ts.net";
      bootstrapCommand = "/run/current-system/sw/bin/quash server --print-fingerprint --cert-dir /var/lib/quash";
    };
  };
}
