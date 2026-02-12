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
          rev = "186b672b4cb02e9c3ded29984a890bddd11929ae";
          sha256 = "sha256-Ci6apbmtG6biigbOzBMU9YgTC7LLi+Um88/sHKarF40=";
        };
      }
      {
        name = "zsh-gwt-skim";
        src = pkgs.fetchFromGitHub {
          owner = "pranc1ngpegasus";
          repo = "zsh-gwt-skim";
          rev = "14af013c875dff94c3fdc3089e808a8785248625";
          sha256 = "sha256-2Pf1NzgA8wW78hGDt2mzwAS1h8tdWUyt04hgvsiwvso=";
        };
      }
    ];
  };
}
