{ pkgs, ... }:
{
  home.packages = [
    pkgs.agent-browser
  ];

  # agent-browser はプロジェクト直下の ./agent-browser.json では cdp と pinTab を無視するため、
  # これらはユーザー単位の ~/.agent-browser/config.json に置く必要がある。
  home.file.".agent-browser/config.json".text = builtins.toJSON {
    cdp = "http://127.0.0.1:9222";
    pinTab = true;
    idleTimeout = "10m";
  };
}
