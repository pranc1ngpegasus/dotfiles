{ lib, pkgs, ... }:
{
  # クリップボードへ書くコマンドは表示サーバーの種類で変わる。X11 では xsel と xclip、
  # Wayland では wl-clipboard が使える。mosh や SSH で接続しただけのセッションには
  # 表示サーバーが無く、これらは動かない。その場合のコピーは tmux 自身が OSC 52 を
  # 端末へ送ることで成立するため、ここで入れるのは表示サーバーがあるときに
  # tmux-yank や Neovim が使うコマンドである。
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (
    with pkgs;
    [
      wl-clipboard
      xclip
      xsel
    ]
  );

  programs.tmux = {
    aggressiveResize = true;
    clock24 = true;
    enable = true;
    escapeTime = 0;
    historyLimit = 100000;
    keyMode = "vi";
    prefix = "C-q";
    terminal = "tmux-256color";
    shell = "${pkgs.bashInteractive}/bin/bash";
    extraConfig = ''
      set-environment -gu __HM_SESS_VARS_SOURCED
      bind-key = select-layout even-horizontal
      set-option -ag terminal-overrides ',xterm-256color:RGB'
      # tmux は clipboard 対応と見なした端末にだけコピー内容を OSC 52 で書き出す。
      # mosh は接続先の TERM を xterm-256color にするので既定のままで送られる。
      # 接続元の tmux の中から ssh で attach したときは tmux-256color になるため、
      # その端末にも clipboard を教えておく。
      set-option -ag terminal-features 'tmux-256color:clipboard'
      set-option -g allow-passthrough on
      set-option -g allow-rename on
      set-option -g automatic-rename on
      set-option -g alternate-screen on
      set-option -g extended-keys on
      set-option -g extended-keys-format csi-u
      set-option -g focus-events on
      set-option -g pane-active-border-style "fg=#84a0c6"
      set-option -g pane-border-style "fg=#1e2132"
      set-option -g renumber-windows on
      set-option -g set-clipboard on
      set-option -g status-interval 1
      set-option -g status-left "#[fg=#c6c8d1] #h "
      set-option -g status-left-length 40
      set-option -g status-position bottom
      set-option -g status-right "#[fg=#39ffb6,bold] %Y/%m/%d %H:%M "
      set-option -g status-right-length 20
      set-option -g status-style "fg=#444b71,bg=#0f1117"
      set-option -ag update-environment " LC_TERMINAL"
      set-option -g window-status-current-format " #I:#W "
      set-option -g window-status-current-style "fg=#c6c8d1,bg=#1e2132,bold"
      set-option -g window-status-format " #I:#W "
      set-option -g window-status-style "fg=#444b71,bg=default"
    '';
    plugins = with pkgs; [
      tmuxPlugins.pain-control
      {
        plugin = tmuxPlugins.yank;
        # tmux-yank は pbcopy や xsel を探してコピー用コマンドに使う。mosh や SSH で
        # 接続したセッションには表示サーバーが無いため、xsel は必ず失敗する。表示
        # サーバーが無いときだけ、tmux の OSC 52 で端末のクリップボードへ書くように
        # 上書きする。yank.tmux はこの option を読んでキーを束縛するので、その実行より
        # 前に設定が要る。Home Manager はプラグインの extraConfig を run-shell より
        # 前に書く。
        extraConfig = ''
          set-option -g @override_copy_command 'if command -v pbcopy >/dev/null 2>&1; then pbcopy; elif [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then wl-copy; elif [ -n "$DISPLAY" ] && command -v xsel >/dev/null 2>&1; then xsel -i --clipboard; elif [ -n "$DISPLAY" ] && command -v xclip >/dev/null 2>&1; then xclip -selection clipboard; else tmux load-buffer -w -; fi'
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];
  };
}
