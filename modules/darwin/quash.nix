{
  inputs,
  ...
}:
{
  nixpkgs.overlays = [
    inputs.quash.overlays.default
  ];
}
