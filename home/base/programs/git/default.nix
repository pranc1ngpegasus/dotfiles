{
  config,
  pkgs,
  ...
}:
let
  _1passwordPath =
    if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "${pkgs._1password-gui}/bin/op-ssh-sign";
in
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
        "ssh" = {
          program = _1passwordPath;
        };
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
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrxAPvOxoy8a5y3hp9iKTWGyk+qgBTYv8DgfTnqQR8/";
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
