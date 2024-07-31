{
  pkgs,
  config,
  ...
}: let
  gpg_ssh_program =
    if pkgs.system == "aarch64-darwin"
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else "";
in {
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
      commit = {
        gpgsign = true;
      };
      gpg = {
        format = "ssh";
        "ssh" = {
          program = gpg_ssh_program;
        };
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
      user = {
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrxAPvOxoy8a5y3hp9iKTWGyk+qgBTYv8DgfTnqQR8/";
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
