{
  # amd-pstate を passive モードにして governor を schedutil にする。active (EPP)
  # モードでは governor が powersave と performance だけになり、schedutil は
  # scaling_available_governors に現れないため passive モードが必要である。
  # schedutil はスケジューラの使用率に応じて desired performance を要求するので、
  # 軽負荷時は低いクロックに落ちて発熱が減る。
  boot.kernelParams = [ "amd_pstate=passive" ];

  # powerManagement.cpuFreqGovernor は使わない。このオプションは boot.kernelModules に
  # cpufreq_schedutil を足すが、この kernel では schedutil が builtin
  # (CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y) で module が無く、systemd-modules-load.service が
  # 失敗する。そのため sysfs に直接書く。
  boot.kernel.sysfs.devices.system.cpu.cpufreq."policy[0-9]*".scaling_governor = "schedutil";
}
