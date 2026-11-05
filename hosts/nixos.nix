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

  # Tailscale や mosh の接続が切断される問題への対策として、Ryzen の deep
  # c-state (C6 など) を無効化する。
  boot.kernelParams = [ "processor.max_cstate=1" ];

  # カーネルに溜めさせる dirty ページの上限を下げる。既定の vm.dirty_ratio=20% は
  # 60GiB のメモリで 12GiB まで書き戻しを遅らせるため、ビルドが数 GiB を一気に
  # 書き出すと、その返済の間 I/O を待つすべてのプロセスが止まる。上限を小さくすると
  # 書き戻しが常時細く流れ、対話操作の待ち時間が平準化される。dirty_bytes を設定すると
  # dirty_ratio は無視されるので、background 側も bytes で揃える。background を既定の
  # 10% のままにすると dirty_bytes に達するまで書き戻しが始まらず、書き込み側が
  # 同期で待たされる。
  boot.kernel.sysctl = {
    "vm.dirty_background_bytes" = 268435456;
    "vm.dirty_bytes" = 1073741824;
  };

  # メモリ圧迫時に OOM killer が動くまでの余裕を作る。
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  my.primaryUser = user;

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
      "dialout"
    ];
    hashedPasswordFile = config.age.secrets.user-password.path;
    openssh.authorizedKeys.keys = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBJdfa70C6n2QYCyhv8UrhVWz1bDoLOIopadWJaDMoiU/cUi9265Qw6RZJ67NjxVhmaJHBQr8nhYFuZUt391xPsQAAAAEc3NoOg== pranc1ngpegasus@M4MacBookAir"
    ];
  };
}
