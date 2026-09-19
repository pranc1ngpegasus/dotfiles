{
  services.eternal-terminal.enable = true;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
