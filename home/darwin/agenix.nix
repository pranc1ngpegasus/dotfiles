{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  secretRules = import ../../secrets/secrets.nix;
  environmentSecretRules = lib.filterAttrs (
    name: rule:
    lib.hasSuffix ".age" name
    && rule ? publicKeys
    && rule.publicKeys != [ ]
    && (rule.loadAsEnvironment or false)
  ) secretRules;
  environmentSecretNames = map (lib.removeSuffix ".age") (builtins.attrNames environmentSecretRules);
  environmentSecretPaths = map (name: config.age.secrets.${name}.path) environmentSecretNames;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.config/agenix/age.agekey"
    ];
    secrets = lib.mapAttrs' (
      name: _:
      lib.nameValuePair (lib.removeSuffix ".age" name) {
        file = ../../secrets + "/${name}";
      }
    ) environmentSecretRules;
  };

  home.packages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.age
  ];

  programs.bash.initExtra = lib.mkAfter (
    lib.optionalString (environmentSecretPaths != [ ]) ''
      for _agenix_env_file in ${
        lib.concatMapStringsSep " " (path: ''"${path}"'') environmentSecretPaths
      }; do
        if [[ ! -r "$_agenix_env_file" ]]; then
          continue
        fi

        while IFS='=' read -r _agenix_env_name _agenix_env_value || [[ -n "$_agenix_env_name" ]]; do
          if [[ "$_agenix_env_name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
            export "$_agenix_env_name=$_agenix_env_value"
          fi
        done < "$_agenix_env_file"
      done
      unset _agenix_env_file _agenix_env_name _agenix_env_value
    ''
  );
}
