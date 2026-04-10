{ ... }:
{
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;

    # Ctrl-T / Alt-C のデフォルトソース
    defaultCommand = "rg --files --hidden --follow --glob '!.git/*' --glob '!node_modules/*' --glob '!targets/*'";
    defaultOptions = [
      "--height 40%"
      "--layout reverse"
      "--inline-info"
    ];
    fileWidgetOptions = [
      "--preview 'head -100 {}'"
    ];

    # tmux 内では fzf-tmux の popup を使う
    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [
        "-p"
        "80%,60%"
      ];
    };
  };
}
