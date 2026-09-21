{
  inputs,
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      grok
      opencode2
    ];
  };
}
