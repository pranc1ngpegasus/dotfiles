{
  # amd-pstate-epp の performance 設定。governor は既定の powersave のままにして
  # 周波数の下限を上げず、EPP だけを performance に寄せる。performance governor は
  # 下限を nominal perf (この機体では 2.5 GHz) まで引き上げるため、アイドル時と
  # 軽負荷時の発熱が増える。EPP を寄せるだけなら、ピーク性能を保ったまま低負荷時は
  # 低いクロックに落ちる。
  boot.kernel.sysfs.devices.system.cpu.cpufreq."policy[0-9]*".energy_performance_preference =
    "performance";
}
