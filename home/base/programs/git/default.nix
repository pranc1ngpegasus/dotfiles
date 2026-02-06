{
  config,
  pkgs,
  ...
}: let
  _1passwordPath =
    if pkgs.system == "aarch64-darwin"
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else "${pkgs._1password-gui}/bin/op-ssh-sign";
in {
  programs.git = {
    enable = true;
    userName = "pranc1ngpegasus";
    userEmail = "temma.fukaya@mokmok.dev";
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrxAPvOxoy8a5y3hp9iKTWGyk+qgBTYv8DgfTnqQR8/";
      format = "ssh";
      signByDefault = true;
      signer = _1passwordPath;
    };
    extraConfig = {
      core = {
        editor = "nvim";
      };
      ghq = {
        root = config.home.homeDirectory + "/ghq";
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        default = "current";
      };
      url."ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
      };
    };
    ignores = [
      ".DS_Store"
      ".claude/*"
      ".direnv"
      ".env"
      ".envrc"
      "flake.lock"
      "flake.nix"
      "go.work"
      "go.work.sum"
      ".zettelkasten/"
    ];
  };
}
