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
          rev = "f2bede7033983c41cffbf391bb1370bbc45418ed";
          sha256 = "sha256-DTP+XE2KuewBw6Zx9Yx3hF0cUcFYFFTKUVSWI9PW3gM=";
        };
      }
      {
        name = "zsh-gwt-skim";
        src = pkgs.fetchFromGitHub {
          owner = "pranc1ngpegasus";
          repo = "zsh-gwt-skim";
          rev = "bebfe0337d6c33ca8ca66486ebce9773a0795994";
          sha256 = "sha256-vCLfn/oK8MAs3OE3XOIUOnvADJ8DlFAzWRgjKPLE0RI=";
        };
      }
    ];
  };
}
