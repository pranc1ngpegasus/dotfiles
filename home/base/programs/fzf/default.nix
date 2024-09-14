{...}: {
  home = {
    sessionVariables = {
      FZF_LEGACY_KEYBINDINGS = 0;
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "rg --files --hidden --follow --glob '!.git/*' --glob '!node_modules/*' --glob '!targets/*'";
    defaultOptions = [
      "--height 40%"
      "--layout reverse-list"
      "--inline-info"
    ];
    fileWidgetOptions = [
      "--preview 'head -100 {}'"
    ];
    tmux = {
      enableShellIntegration = true;
    };
  };
}
