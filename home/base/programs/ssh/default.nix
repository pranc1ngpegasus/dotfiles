{pkgs, ...}: let
  _1passwordSockPath =
    if pkgs.system == "aarch64-darwin"
    then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "~/.1password/agent.sock";
in {
  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityAgent "${_1passwordSockPath}"
    '';
  };
}
