{inputs, ...}: {
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = ''
      eval "$(fnm env --use-on-cd)"
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
