{
  config,
  lib,
  pkgs,
  ...
}:
let
  # ob sync-setup はこのパスを vault の登録に書き込むので、サービスと一致させる。
  vault = "${config.home.homeDirectory}/obsidian";
in
{
  home.packages = [ pkgs.obsidian-headless ];

  systemd.user.services.obsidian-sync = {
    Unit.Description = "Obsidian Sync (headless)";
    Service = {
      ExecStart = "${lib.getExe pkgs.obsidian-headless} sync --continuous --path ${vault}";
      Restart = "on-failure";
      RestartSec = 30;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
