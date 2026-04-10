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

      # Ctrl+G で ghq list を fzf に流してファジーに選び、選択した repo に cd する。
      # tmux セッション内では fzf-tmux の popup、セッション外では通常の fzf にフォールバック。
      __ghq_cd() {
        local dir finder
        if [[ -n "''${TMUX:-}" ]]; then
          finder=(fzf-tmux -p 80%,60%)
        else
          finder=(fzf --height 40% --layout reverse)
        fi
        dir=$(ghq list --full-path | "''${finder[@]}" --prompt 'ghq> ') || return
        [[ -n "$dir" ]] && cd "$dir"
      }
      bind -x '"\C-g": __ghq_cd'
    '';
  };
}
