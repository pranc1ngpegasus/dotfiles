{ inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age = {
    identityPaths = [ "/home/pranc1ngpegasus/.config/agenix/age.agekey" ];
    secrets = {
      user-password = {
        file = ../../secrets/user-password.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
