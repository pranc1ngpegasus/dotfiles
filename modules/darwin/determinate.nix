{ inputs, ... }:
{
  imports = [
    inputs.determinate.darwinModules.default
  ];

  # Determinate Nixd はディスクの空き容量に応じて GC を自動実行する。macOS でも同じ
  # 挙動に依存することを宣言的に固定しておく。macOS では Determinate が
  # /etc/nix/nix.conf を管理するため nix-darwin の nix.settings は使えず、追記は
  # determinateNix.customSettings から /etc/nix/nix.custom.conf へ書く。
  determinateNix.determinateNixd.garbageCollector.strategy = "automatic";
}
