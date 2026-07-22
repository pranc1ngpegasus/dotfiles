{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.config/agenix/age.agekey"
    ];
    secrets.sakana-api-key.file = ../../secrets/sakana-api-key.age;
  };

  home.packages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.age
  ];

  programs.bash.initExtra = lib.mkAfter ''
    _sakana_api_key_file="${config.age.secrets.sakana-api-key.path}"
    if [[ -r "$_sakana_api_key_file" && -s "$_sakana_api_key_file" ]]; then
      export SAKANA_API_KEY="$(< "$_sakana_api_key_file")"
    fi
    unset _sakana_api_key_file
  '';
}
