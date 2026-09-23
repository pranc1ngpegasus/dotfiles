{
  config,
  isDarwin,
  inputs,
  ...
}:
{
  imports = [
    (
      if isDarwin then
        inputs.home-manager.darwinModules.home-manager
      else
        inputs.home-manager.nixosModules.home-manager
    )
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = !isDarwin;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit inputs;
    };
    users.${config.my.primaryUser} = import (if isDarwin then ../home/darwin else ../home/linux);
  };
}
