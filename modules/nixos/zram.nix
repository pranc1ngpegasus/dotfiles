{
  # このホストはディスクのスワップを持たない (hosts/nixos/hardware.nix の
  # swapDevices = []) ため、メモリが尽きる前に退避先を用意する。zram は RAM の
  # 一部を zstd で圧縮してスワップに見せるので、ディスク I/O を伴わずに済む。
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
}
