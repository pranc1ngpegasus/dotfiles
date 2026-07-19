{ ... }:
{
  home.sessionPath = [ "$HOME/.local/bin" ];

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

      if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == "declare -a"* ]]; then
        _prompt_command_joined=$(IFS=';'; printf '%s' "''${PROMPT_COMMAND[*]}")
        unset PROMPT_COMMAND
        PROMPT_COMMAND="$_prompt_command_joined"
        unset _prompt_command_joined
      fi

      PROMPT_COMMAND="history -a; history -n; ''${PROMPT_COMMAND:-}"

      ghq() {
        if [[ "$1" == "cd" ]]; then
          local dir
          dir=$(command ghq list --full-path | fzf-tmux -d 40% --prompt 'ghq> ') \
            && [[ -n "$dir" ]] && cd "$dir"
        else
          command ghq "$@"
        fi
      }

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

      bind '"\C-g": "\C-u ghq cd\C-m"'
      bind '"\C-w": "\C-u gwt cd\C-m"'
    '';
  };
}
