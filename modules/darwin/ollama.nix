{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.ollama
  ];

  launchd.user.agents.ollama = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];
      RunAtLoad = true;
      KeepAlive = {
        Crashed = true;
        SuccessfulExit = false;
      };
      ProcessType = "Background";
      EnvironmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "32768";
        OLLAMA_HOST = "127.0.0.1:11434";
      };
    };
  };
}
