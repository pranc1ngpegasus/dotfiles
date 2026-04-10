{ ... }:
{
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.bash = {
    enable = true;

    historySize = 200000;
    historyFileSize = 200000;

    historyControl = [
      "ignoredups"
      "ignorespace"
      "erasedups"
    ];

    shellOptions = [
      "histappend"
      "checkwinsize"
      "globstar"
    ];

    initExtra = ''
      PS1='\[\e[37m\]\w\[\e[0m\]\n\[\e[32m\]>\[\e[0m\] '

      PROMPT_COMMAND="history -a; history -n; ''${PROMPT_COMMAND:-}"
    '';
  };
}
