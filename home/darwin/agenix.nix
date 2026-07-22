{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  environmentSecrets = {
    SAKANA_API_KEY = ../../secrets/sakana-api-key.age;
  };
  environmentSecretNames = builtins.attrNames environmentSecrets;
  secretName = file: lib.removeSuffix ".age" (builtins.baseNameOf file);
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  assertions = [
    {
      assertion = lib.all (
        name: builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null
      ) environmentSecretNames;
      message = "environmentSecrets の属性名には有効な環境変数名を指定する必要がある。";
    }
    {
      assertion = lib.all (file: lib.hasSuffix ".age" (builtins.baseNameOf file)) (
        builtins.attrValues environmentSecrets
      );
      message = "environmentSecrets には .age ファイルを指定する必要がある。";
    }
  ];

  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.config/agenix/age.agekey"
    ];
    secrets = lib.mapAttrs' (
      _: file: lib.nameValuePair (secretName file) { inherit file; }
    ) environmentSecrets;
  };

  home.packages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.age
  ];

  programs.bash.initExtra = lib.mkAfter ''
    ${lib.concatMapStringsSep "\n" (
      environmentName:
      let
        name = secretName environmentSecrets.${environmentName};
      in
      ''
        _agenix_secret_file="${config.age.secrets.${name}.path}"
        if [[ -r "$_agenix_secret_file" && -s "$_agenix_secret_file" ]]; then
          export ${environmentName}="$(< "$_agenix_secret_file")"
        fi
      ''
    ) environmentSecretNames}
    unset _agenix_secret_file
  '';
}
