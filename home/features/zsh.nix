{inputs, ...}: {
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    enableAutosuggestions = true;
    plugins = [
      {
        name = "zsh-ghq-skim";
        src = inputs.zsh-ghq-skim;
      }
    ];
  };
}
