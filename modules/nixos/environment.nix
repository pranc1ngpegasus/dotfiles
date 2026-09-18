{ pkgs, ... }:
{
  environment.shells = [ pkgs.bashInteractive ];

  environment.systemPackages = with pkgs; [
    tsshd
  ];
}
