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
    extraConfig = {
      core = {
        editor = "nvim";
      };
      commit = {
        gpgsign = true;
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
      push = {
        default = "current";
      };
      url."ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
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
      "flake.lock"
      "flake.nix"
      "go.work"
      "go.work.sum"
      ".zettelkasten/"
    ];
  };
}
