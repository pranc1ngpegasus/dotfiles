{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    initExtra = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    '';
    plugins = [
      {
        name = "zsh-ghq-fzf";
        src = pkgs.fetchFromGitHub {
          owner = "pranc1ngpegasus";
          repo = "zsh-ghq-fzf";
          rev = "main";
          sha256 = "sha256-OOX3UqU3rP6fQ6Cbbg3067EkaSsPfHIfBxltMBxHg04=";
        };
      }
    ];
  };
}
