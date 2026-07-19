{ ... }:
{
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;

    defaultCommand = "rg --files --hidden --follow --glob '!.git/*' --glob '!node_modules/*' --glob '!targets/*'";
    defaultOptions = [
      "--height 40%"
      "--layout reverse"
      "--inline-info"
    ];
    fileWidget.options = [ "--preview 'head -100 {}'" ];
    historyWidget.command = "";

    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [
        "-d"
        "40%"
      ];
    };
  };
}
