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
    shell = "${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      set-option -ag terminal-overrides ',xterm-256color:RGB'
      # ペインを均等幅に揃える
      bind-key = select-layout even-horizontal
      # status line
      ## common
      set-option -g allow-rename on
      set-option -g automatic-rename on
      set-option -g focus-events on
      set-option -g renumber-windows on
      set-option -g status-bg "colour237"
      set-option -g status-fg "colour255"
      set-option -g status-interval 1
      set-option -g status-justify "centre"
      set-option -g status-position "bottom"
      ## window status
      set-option -g window-status-current-format " #I: #{pane_current_command} "
      set-option -g window-status-current-style "fg=colour252,bg=colour27,bold"
      set-option -g window-status-format " #I: #{pane_current_command} "
      set-option -g window-status-style "fg=default,bg=default,bold"
      ## window status left
      set-option -g status-left "#[fg=colour252,bg=colour239] Session: #S #[default]"
      set-option -g status-left-length 70
      ## window status right
      set-option -g status-right "#[fg=colour252,bg=colour239] %Y/%m/%d(%a) %H:%M:%S #[default]"
      set-option -g status-right-length 70
      ## pane border
      set-option -g pane-active-border-style "fg=colour27,bg=default"
      set-option -g pane-border-format " #P: #{pane_current_path} - #{pane_current_command} "
      set-option -g pane-border-status top
      set-option -g pane-border-style "fg=default,bg=default"
    '';
    plugins = with pkgs; [
      tmuxPlugins.pain-control
      tmuxPlugins.yank
    ];
  };
}
