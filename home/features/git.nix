{config, ...}: {
  home = {
    sessionVariables = {
      GHQ_SELECTOR = "fzf-tmux";
    };
  };

  programs.git = {
    enable = true;
    userName = "Pranc1ngPegasus";
    userEmail = "ride.or.die.2215@icloud.com";
    extraConfig = {
      core = {
        editor = "nvim";
      };
      push = {
        default = "current";
      };
      init = {
        defaultBranch = "main";
      };
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      ghq = {
        root = config.home.homeDirectory + "/ghq";
      };
    };
    ignores = [
      ".envrc"
      ".env"
      ".DS_Store"
      ".tool-versions"
    ];
  };
}
