{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.credentials;
in {
  options.clement.credentials = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        file = mkOption {
          type = types.path;
        };

        format = mkOption {
          type = types.nullOr (types.enum [ "json" "yaml" "dotenv" ]);
          default = null;
        };

        user = mkOption {
          type = types.str;
          default = "root";
        };

        group = mkOption {
          type = types.str;
          default = "root";
        };

        mode = mkOption {
          type = types.str;
          default = "0440";
        };

        key = mkOption {
          type = types.str;
          default = "/nix/key.txt";
        };

        before = mkOption {
          type = types.listOf types.str;
          default = [];
        };

        service = mkOption {
          type = types.nullOr types.str;
          default = null;
        };

        secrets = mkOption {
          type = let
            credentialName = name;
          in types.attrsOf (types.submodule ({ name, ... }: {
            options = {
              extract = mkOption {
                type = types.str;
              };

              path = mkOption {
                type = types.str;
                default = config.clement.secrets."${credentialName}-${name}".path;
                internal = true;
                readOnly = true;
              };
            };
          }));
          default = {};
        };
      };
    }));
    default = {};
  };

  config = {
    clement.secrets = mkMerge (flatten (mapAttrsToList (credentialName: value:
      mapAttrsToList (secretName: secret: {
        "${credentialName}-${secretName}" = {
          inherit (value) file format user group mode key;
          inherit (secret) extract;
          before = value.before ++ optional (value.service != null) "${value.service}.service";
        };
      }) value.secrets
    ) cfg));

    systemd.services = mkMerge (mapAttrsToList (_: value: {
      "${value.service}".serviceConfig.LoadCredential =
        mapAttrsToList (name: secret: "${name}:${secret.path}") value.secrets;
    }) (filterAttrs (_: value: value.service != null) cfg));
  };
}
