{inputs, ...}: {
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = ''
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
      export PATH="$HOME/go/bin:$PATH"
      eval "$(fnm env --use-on-cd)"
      eval $(/opt/homebrew/bin/brew shellenv)
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    '';
    plugins = [
      {
        name = "zsh-ghq-fzf";
        src = inputs.zsh-ghq-fzf;
      }
    ];
  };
}
