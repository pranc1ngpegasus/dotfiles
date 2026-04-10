{
  config,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    settings = {
      core = {
        editor = "nvim";
      };
      commit = {
        gpgsign = true;
      };
      diff = {
        colorMoved = "default";
      };
      credential = {
        "https://github.com" = {
          helper = "!gh auth git-credential";
        };
      };
      fetch = {
        prune = true;
        pruneTags = true;
      };
      ghq = {
        root = config.home.homeDirectory + "/ghq";
      };
      gpg = {
        format = "ssh";
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictstyle = "zdiff3";
      };
      rebase = {
        autosquash = true;
        updateRefs = true;
      };
      rerere = {
        enabled = true;
      };
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      user = {
        name = "pranc1ngpegasus";
        email = "temma.fukaya@mokmok.dev";
        signingKey = "${config.home.homeDirectory}/.ssh/id_ed25519_sign.pub";
      };
    };
    ignores = [
      ".DS_Store"
      ".claude/*"
      ".direnv"
      ".env"
      ".envrc"
      "go.work"
      "go.work.sum"
      ".zettelkasten/"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = false;
    };
  };
}
