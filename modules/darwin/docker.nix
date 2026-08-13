{
  pkgs,
  ...
}:
{
  launchd.user.agents.colima = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
      ];
      RunAtLoad = true;
      ProcessType = "Background";
    };
  };
}
