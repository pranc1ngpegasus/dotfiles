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
          rev = "3462279b0e2645081b45c257c8ab3d2d340858b1";
          sha256 = "sha256-TPf3JtJzKRboACbQoK47mlBertjVtDJtOE0+iGpXAvk=";
        };
      }
      {
        name = "zsh-gwt-skim";
        src = pkgs.fetchFromGitHub {
          owner = "pranc1ngpegasus";
          repo = "zsh-gwt-skim";
          rev = "80d2f2156b93cdcbd389b6a3ec914fbecb24b6b9";
          sha256 = "sha256-zuBbrVGVIa5lFcfymy9deTlYTHUPVsbOOccLnzSdVB8=";
        };
      }
    ];
  };
}
