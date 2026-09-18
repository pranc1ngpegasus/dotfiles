let
  bridge = "br0";
  uplink = "enp3s0";
  downlink = "enp4s0";

  portProfile = interface: uuid: {
    connection = {
      id = "${bridge}-${interface}";
      inherit uuid;
      type = "ethernet";
      "interface-name" = interface;
      controller = bridge;
      "port-type" = "bridge";
      autoconnect = true;
    };
  };
in
{
  networking.networkmanager = {
    enable = true;

    settings.main.no-auto-default = "*";

    ensureProfiles.profiles = {
      ${bridge} = {
        connection = {
          id = bridge;
          uuid = "7ff52602-852e-41d0-b33e-55f04bccb859";
          type = "bridge";
          "interface-name" = bridge;
          autoconnect = true;
          "autoconnect-ports" = true;
        };
        bridge.stp = false;
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      "${bridge}-${uplink}" = portProfile uplink "3fadc443-f1a0-4b0b-ad94-d1e42b26a2eb";
      "${bridge}-${downlink}" = portProfile downlink "46045d8c-3312-4410-a807-1e9e3e7edcaa";
    };
  };

  networking.firewall = {
    enable = true;
    allowedUDPPortRanges = [
      {
        from = 61001;
        to = 61999;
      }
    ];
  };
}
