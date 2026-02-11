{
  config,
  pkgs,
  ...
}:
{
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "emacs";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 200000;
      save = 200000;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
    };
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
          rev = "5d030e7aef94eb1804a0f216a801c47bd357d2a4";
          sha256 = "sha256-U/b7zdP5y1k5kADNy7hf7BYr9H7AZsL6arW1qOozdxk=";
        };
      }
      {
        name = "zsh-gwt-skim";
        src = pkgs.fetchFromGitHub {
          owner = "pranc1ngpegasus";
          repo = "zsh-gwt-skim";
          rev = "1cb2450bfa74e31194503805d9cec22711aa7fa4";
          sha256 = "sha256-gVdDnvEUG3JiuDDVWrDeOBlmF+C7KbQwNiIVDukT+xY=";
        };
      }
    ];
  };
}
