{
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedUDPPortRanges = [
      {
        from = 60000;
        to = 61000;
      }
    ];
  };
}
