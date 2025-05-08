{...}: {
  programs.skim = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden --follow --glob '!.git/*' --glob '!node_modules/*' --glob '!targets/*'";
    defaultOptions = [
      "--height 40%"
      "--layout reverse-list"
      "--inline-info"
    ];
    fileWidgetOptions = [
      "--preview 'head -100 {}'"
    ];
  };
}
