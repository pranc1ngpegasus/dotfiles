{ pkgs, ... }:
{
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
      bind-key = select-layout even-horizontal
      set-option -ag terminal-overrides ',xterm-256color:RGB'
      set-option -g allow-passthrough on
      set-option -g allow-rename on
      set-option -g automatic-rename on
      set-option -g extended-keys on
      set-option -g focus-events on
      set-option -g pane-active-border-style "fg=#84a0c6"
      set-option -g pane-border-style "fg=#1e2132"
      set-option -g renumber-windows on
      set-option -g status-interval 1
      set-option -g status-left "#[fg=#c6c8d1] #h "
      set-option -g status-left-length 40
      set-option -g status-position bottom
      set-option -g status-right "#[fg=#39ffb6,bold] %Y/%m/%d %H:%M "
      set-option -g status-right-length 20
      set-option -g status-style "fg=#444b71,bg=#0f1117"
      set-option -g window-status-current-format " #I:#W "
      set-option -g window-status-current-style "fg=#c6c8d1,bg=#1e2132,bold"
      set-option -g window-status-format " #I:#W "
      set-option -g window-status-style "fg=#444b71,bg=default"
    '';
    plugins = with pkgs; [
      tmuxPlugins.pain-control
      tmuxPlugins.yank
    ];
  };
}
