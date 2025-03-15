{ config, lib, pkgs, utils, ... }:

with lib; let
  secret = types.submodule ({ name, config, ... }: {
    options = {
      text = mkOption {
        type = types.str;
        default = "";
        description = "sops encrypted secret file";
      };

      file = mkOption {
        type = types.path;
        default = pkgs.writeText name config.text;
        description = "sops encrypted secret file";
      };

      extract = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "document sub-part to extract";
      };

      user = mkOption {
        type = types.str;
        default = "root";
        description = "owner of the secret file";
      };

      group = mkOption {
        type = types.str;
        default = "root";
        description = "group of the secret file";
      };

      mode = mkOption {
        type = types.str;
        default = "0400";
        description = "permissions of the secret file";
      };

      key = mkOption {
        type = types.str;
        default = "/nix/key.txt"; # default to /nix because tmpfs as root
        description = "age identity file";
      };

      before = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "services that should be started after the secret is decrypted";
      };

      path = mkOption {
        type = types.str;
        default = "/run/secrets/${name}";
        internal = true;
        readOnly = true;
      };
    };
  });
in {
  options.clement.secrets = mkOption {
    type = types.attrsOf secret;
    default = {};
  };

  config = {
    systemd.services = attrsets.mapAttrs' (name: { file, extract, user, group, mode, key, before, path, ... }: {
      name = "secrets-${utils.escapeSystemdPath name}";
      value = {
        inherit before;
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          rm -rf ${path}
          ${pkgs.sops}/bin/sops --decrypt --output ${path} ${if extract != null then "--extract '${extract}'" else ""} ${file}
          chown ${user}:${group} ${path}
          chmod ${mode} ${path}
        '';
        preStop = "rm -rf ${path}";
        environment.SOPS_AGE_KEY_FILE = "${key}";
      };
    }) config.clement.secrets;

    # Ensure /run/secrets exist
    systemd.tmpfiles.rules = [
      "d /run/secrets 0755 root root -"
    ];
  };
}
