{ ... }:
{
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.bash = {
    enable = true;

    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      wn = "gwt new";
    };

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

      # Ghostty の bash integration は bash 5.1+ で PROMPT_COMMAND を配列に
      # 切り替える。一方で bash-preexec (atuin が依存) の install ロジックは
      # PROMPT_COMMAND が配列だと install string を要素 [1] 以降から取り除けず、
      # 毎プロンプトで `trap - DEBUG` が走って DEBUG trap が消えてしまう。
      # 結果として atuin の preexec hook が発火しなくなり、直前のコマンドが
      # 履歴に残らない。bash-preexec が読み込まれる前に文字列へ正規化する。
      if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == "declare -a"* ]]; then
        _prompt_command_joined=$(IFS=';'; printf '%s' "''${PROMPT_COMMAND[*]}")
        unset PROMPT_COMMAND
        PROMPT_COMMAND="$_prompt_command_joined"
        unset _prompt_command_joined
      fi

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
      # `gwt new [base]` でメイン worktree と同じ階層にランダムな名前の
      # worktree を作る。base を省略した場合は origin/main を使う。
      gwt() {
        case "$1" in
          cd)
            if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              printf 'gwt cd: not a git repository\n' >&2
              return 1
            fi
            local selection dir
            selection=$(git worktree list | fzf-tmux -d 40% --prompt 'worktree> ') \
              && dir=''${selection%% *} \
              && [[ -n "$dir" ]] && cd "$dir"
            ;;
          new)
            if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              printf 'gwt new: not a git repository\n' >&2
              return 1
            fi
            local worktree_list main_worktree name destination base
            worktree_list="$(git worktree list --porcelain)" || return
            main_worktree="$(
              printf '%s\n' "$worktree_list" |
                sed -n '1s/^worktree //p'
            )"

            base="''${2:-origin/main}"
            name="$(basename "$main_worktree")-$(openssl rand -hex 3)"
            destination="$(dirname "$main_worktree")/$name"

            git worktree add "$destination" "$base"
            ;;
          *)
            printf 'gwt: unknown subcommand: %s\n' "$1" >&2
            return 1
            ;;
        esac
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
