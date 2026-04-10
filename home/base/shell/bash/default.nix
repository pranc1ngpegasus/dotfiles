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

      # `ghq cd` で ghq list を fzf-tmux に流してファジーに選び、選択した repo に即 cd する。
      # 他の subcommand (get, root, list, …) は本来の ghq にそのまま委譲する。
      # fzf-tmux -d 40% で画面下部 40% の高さ・全幅の split を開く。
      ghq() {
        if [[ "$1" == "cd" ]]; then
          local dir
          dir=$(command ghq list --full-path | fzf-tmux -d 40% --prompt 'ghq> ') \
            && [[ -n "$dir" ]] && cd "$dir"
        else
          command ghq "$@"
        fi
      }

      # `gwt cd` で現在の git リポジトリの worktree 一覧を fzf-tmux に流して
      # ファジーに選び、選択した worktree に即 cd する。
      gwt() {
        if [[ "$1" == "cd" ]]; then
          if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            printf 'gwt cd: not a git repository\n' >&2
            return 1
          fi
          local selection dir
          selection=$(git worktree list | fzf-tmux -d 40% --prompt 'worktree> ') \
            && dir=''${selection%% *} \
            && [[ -n "$dir" ]] && cd "$dir"
        else
          printf 'gwt: unknown subcommand: %s\n' "$1" >&2
          return 1
        fi
      }

      # Ctrl+G / Ctrl+W でそれぞれ `ghq cd` / `gwt cd` を readline にそのまま流し込む。
      # bind -x ではなくマクロを使うことで、cd がメイン shell ループで走り、
      # PROMPT_COMMAND 経由で direnv などの hook が正しく発火する。
      # 先頭のスペースは histcontrol=ignorespace で history から除外するため。
      # なお Ctrl+W はデフォルトで unix-word-rubout (直前の単語を削除) に割り当てられているため上書きされる。
      bind '"\C-g": "\C-u ghq cd\C-m"'
      bind '"\C-w": "\C-u gwt cd\C-m"'
    '';
  };
}
