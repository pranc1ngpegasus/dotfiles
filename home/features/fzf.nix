{...}: {
  home = {
    sessionVariables = {
      FZF_LEGACY_KEYBINDINGS = 0;
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "rg --files --hidden --follow --glob '!.git/*' --glob '!node_modules/*'";
    defaultOptions = [
      "--height 40%"
      "--layout reverse-list"
      "--inline-info"
    ];
    fileWidgetOptions = [
      "--preview \"bat --color=always --style=header,grid --line-range :100 {}\""
    ];
    tmux = {
      enableShellIntegration = true;
    };
  };
}
