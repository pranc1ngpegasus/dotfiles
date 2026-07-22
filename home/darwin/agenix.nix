{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/agenix/age.agekey"
  ];

  home.packages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.age
  ];
}
