{inputs, ...}: {
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fish-fzf";
        src = inputs.fish-fzf;
      }
      {
        name = "fish-ghq";
        src = inputs.fish-ghq;
      }
      {
        name = "fish-rust";
        src = inputs.fish-rust;
      }
    ];
  };
}
