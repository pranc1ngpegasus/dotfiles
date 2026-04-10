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

    # tmux 内では画面下部 40% を split して fzf-tmux を表示する (全幅、popup ではない)
    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [
        "-d"
        "40%"
      ];
    };
  };
}
