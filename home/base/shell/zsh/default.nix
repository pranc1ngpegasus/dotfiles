{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "emacs";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      PROMPT="%F{white}%c%f
      %F{green}>%f "
    '';
    plugins = [
      {
        name = "zsh-ghq-skim";
        src = pkgs.fetchFromGitHub {
          owner = "pranc1ngpegasus";
          repo = "zsh-ghq-skim";
          rev = "main";
          sha256 = "sha256-U/b7zdP5y1k5kADNy7hf7BYr9H7AZsL6arW1qOozdxk=";
        };
      }
      {
        name = "zsh-gwt-skim";
        src = pkgs.fetchFromGitHub {
          owner = "pranc1ngpegasus";
          repo = "zsh-gwt-skim";
          rev = "main";
          sha256 = "sha256-gVdDnvEUG3JiuDDVWrDeOBlmF+C7KbQwNiIVDukT+xY=";
        };
      }
    ];
  };
}
