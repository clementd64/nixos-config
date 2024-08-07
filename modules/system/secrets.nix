{ config, lib, pkgs, utils, ... }:

with lib; let
  secret = types.submodule {
    options = {
      text = mkOption {
        type = types.str;
        description = "encrypted secret file content";
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

      identity = mkOption {
        type = types.str;
        default = "/etc/ssh/ssh_host_ed25519_key";
        description = "age identity file";
      };
    };
  };
in {
  options.clement.secrets = mkOption {
    type = types.attrsOf secret;
    default = {};
  };

  config = {
    systemd.services = attrsets.mapAttrs' (name: { text, user, group, mode, identity }:
      let
        path = "/run/secrets/${name}";
        file = pkgs.writeText name text;
      in {
        name = "secrets-${utils.escapeSystemdPath name}";
        value = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            rm -rf ${path}
            ${pkgs.age}/bin/age -d -i ${identity} -o ${path} ${file}
            chown ${user}:${group} ${path}
            chmod ${mode} ${path}
          '';
        };
      }
    ) config.clement.secrets;

    # Ensure /run/secrets exist
    systemd.tmpfiles.rules = [
      "d /run/secrets 0755 root root -"
    ];
  };
}
