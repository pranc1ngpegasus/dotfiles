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
        pager = "delta";
      };
      delta = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        true-color = "always";
      };
      diff = {
        colorMoved = "dimmed_zebra";
      };
      push = {
        default = "current";
      };
      init = {
        defaultBranch = "main";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      merge = {
        conflictStyle = "diff3";
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
