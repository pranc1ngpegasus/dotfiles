{ inputs, ... }:
let
  hosts = import ./hosts.nix;
in
{
  flake.darwinConfigurations = builtins.mapAttrs (
    _: host:
    inputs.nix-darwin.lib.darwinSystem {
      inherit (host) modules;
      specialArgs = { inherit inputs; };
    }
  ) hosts;
}
