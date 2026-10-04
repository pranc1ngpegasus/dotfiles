{
  # CPU の governor を performance に固定する。amd-pstate-epp は performance
  # ポリシーのとき周波数の下限を nominal perf まで引き上げ、EPP は performance
  # に固定して変更を受け付けなくなる。
  powerManagement.cpuFreqGovernor = "performance";
}
