{inputs, ...}: {
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    plugins = [
      {
        name = "zsh-ghq-fzf";
        src = inputs.zsh-ghq-fzf;
      }
    ];
  };
}
