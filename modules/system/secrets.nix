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
    systemd.services = attrsets.mapAttrs' (name: { file, user, group, mode, key, path, ... }: {
      name = "secrets-${utils.escapeSystemdPath name}";
      value = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          rm -rf ${path}
          ${pkgs.sops}/bin/sops --decrypt --output ${path} ${file}
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
