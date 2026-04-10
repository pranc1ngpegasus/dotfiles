{ inputs, ... }:
{
  nixpkgs = {
    overlays = [
      inputs.neovim.overlays.default
    ];
  };
}
