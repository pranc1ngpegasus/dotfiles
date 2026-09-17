{
  config,
  pkgs,
  ...
}:
let
  user = "pranc1ngpegasus";
in
{
  imports = [
    ./nixos-hardware.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "nixos";

  system.stateVersion = "26.05";

  users.mutableUsers = false;

  users.users.${user} = {
    name = user;
    uid = 1000;
    isNormalUser = true;
    home = "/home/${user}";
    shell = pkgs.bashInteractive;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    hashedPasswordFile = config.age.secrets.user-password.path;
    openssh.authorizedKeys.keys = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBJdfa70C6n2QYCyhv8UrhVWz1bDoLOIopadWJaDMoiU/cUi9265Qw6RZJ67NjxVhmaJHBQr8nhYFuZUt391xPsQAAAAEc3NoOg== pranc1ngpegasus@M4MacBookAir"
    ];
  };
}
