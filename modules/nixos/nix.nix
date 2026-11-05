{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    settings.trusted-users = [ "root" ];

    # GC は determinate-nixd がディスク空き容量に応じて自動実行するため、ここでは有効化しない。
    optimise.automatic = true;
  };

  # リモートの対話セッションがビルドに待たされないよう、ビルドを実行する
  # nix-daemon を対話セッションより低い優先度に置く。nice は子プロセスへ継承される
  # ため、daemon が起動した rustc にも効く。cgroup の CPUWeight と IOWeight は
  # ビルド全体に掛かり、dirty ページの書き戻しの重み付けにも使われる。取り合いが
  # 無い間は優先度も重みも結果を変えない。
  systemd.services.nix-daemon.serviceConfig = {
    Nice = 10;
    CPUWeight = 50;
    IOWeight = 50;
  };
}
