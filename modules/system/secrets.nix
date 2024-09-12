{ config, lib, pkgs, utils, ... }:

with lib; let
  secret = types.submodule {
    options = {
      text = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "encrypted secret file content";
      };

      sops = mkOption {
        type = types.nullOr types.path;
        default = null;
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
    assertions = lists.flatten (attrsets.mapAttrsToList (name: value: [
      {
        assertion = value.text != null -> value.sops == null;
        message = "text and sops are mutually exclusive";
      }
      {
        assertion = value.text != null || value.sops != null;
        message = "neither text nor sops provided";
      }
    ]) config.clement.secrets);

    systemd.services = attrsets.mapAttrs' (name: { text, sops, user, group, mode, identity }:
      let
        path = "/run/secrets/${name}";
        decodeCmd = if text != null
          then "${pkgs.age}/bin/age -d -i ${identity} -o ${path} ${pkgs.writeText name text}"
          else "${pkgs.sops}/bin/sops --decrypt --output ${path} ${sops}";
      in {
        name = "secrets-${utils.escapeSystemdPath name}";
        value = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            rm -rf ${path}
            ${decodeCmd}
            chown ${user}:${group} ${path}
            chmod ${mode} ${path}
          '';
          environment.SOPS_AGE_KEY_FILE = mkIf (sops != null) "${identity}";
        };
      }
    ) config.clement.secrets;

    # Ensure /run/secrets exist
    systemd.tmpfiles.rules = [
      "d /run/secrets 0755 root root -"
    ];
  };
}
