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
          rev = "cd3025d8036b4e2c39ebf169b01cd1c3af4431d6";
          sha256 = "sha256-Xm4K2YuO4nzA3jMknL6MNTMxHebl+UrNxESZjyM4oAo=";
        };
      }
      {
        name = "zsh-gwt-skim";
        src = pkgs.fetchFromGitHub {
          owner = "pranc1ngpegasus";
          repo = "zsh-gwt-skim";
          rev = "d0b9c8f8d0c34b69a227d6c48158560a243c0b51";
          sha256 = "sha256-5a9r8c4BKHLCVOQ/wrzv6NkoEsqzFQBfYM9JZSjl7qQ=";
        };
      }
    ];
  };
}
