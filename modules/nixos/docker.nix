{ config, ... }:
{
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # rootless の dockerd は systemd のユーザーサービスとして動くため、ログイン
  # セッションが無くなると止まる。ログアウト後もコンテナを動かし続けられるように
  # linger を有効にする。
  users.users.${config.my.primaryUser}.linger = true;
}
