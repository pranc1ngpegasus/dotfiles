{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  console = {
    useXkbConfig = true;
  };

  environment = {
    gnome.excludePackages = with pkgs; [
      atomix
      cheese
      epiphany
      evince
      geary
      gedit
      gnome-characters
      gnome-music
      gnome-photos
      gnome-tour
      hitori
      iagno
      tali
      totem
    ];
    sessionVariables = {
      # IME
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      QT_QPA_PLATFORM = "wayland";
      XMODIFIERS = "@im=fcitx";
      # Wayland
      NIXOS_OZONE_WL = "1";
      WAYLAND_DISPLAY = "wayland-0";
    };
    systemPackages = with pkgs; [
      firefox
      google-chrome
      ghostty
    ];
    variables = {
      EDITOR = "nvim";
      PKG_CONFIG_PATH = "${pkgs.openssl}/lib/pkgconfig";
    };
  };

  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-skk
        ];
        waylandFrontend = true;
      };
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  security = {
    rtkit.enable = true;
  };

  services = {
    hardware = {
      bolt.enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    printing.enable = true;
    pulseaudio.enable = false;
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  users.users.pranc1ngpegasus = {
    isNormalUser = true;
    description = "pranc1ngpegasus";
    extraGroups = ["networkmanager" "wheel" "docker"];
  };
}
