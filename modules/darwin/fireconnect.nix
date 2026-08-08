{
  fireconnect,
  ...
}:
{
  # flake/fireconnect.nix で flake-parts の packages.fireconnect としてビルドされた
  # CLI をシステム全体で使えるようにする
  environment.systemPackages = [ fireconnect ];
}
