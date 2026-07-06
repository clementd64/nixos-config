{ config, lib, pkgs, utils, ... }:

with lib; let
  cfg = config.clement.acme;

  certModule = types.submodule ({ name, config, ... }: {
    options = {
      certName = mkOption {
        type = types.str;
        default = name;
      };

      domains = mkOption {
        type = types.listOf types.str;
        default = [ config.certName ];
      };

      profile = mkOption {
        type = types.str;
        default = "shortlived";
      };

      reload = mkOption {
        type = types.nullOr types.str;
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

      cert = mkOption {
        type = types.str;
        default = "${cfg.directory}/live/${config.certName}/cert.pem";
        internal = true;
        readOnly = true;
      };

      key = mkOption {
        type = types.str;
        default = "${cfg.directory}/live/${config.certName}/privkey.pem";
        internal = true;
        readOnly = true;
      };
    };
  });
in {
  options.clement.acme = {
    directory = mkOption {
      type = types.str;
      default = "/nix/letsencrypt";
    };

    webroot = mkOption {
      type = types.str;
      default = config.clement.proxy64.http2https.acmeWebroot;
    };

    certificates = mkOption {
      type = types.attrsOf certModule;
      default = {};
    };
  };

  config = mkIf (cfg.certificates != {}) {
    systemd.services = attrsets.mapAttrs' (name: cert: {
      name = "acme-${utils.escapeSystemdPath name}";
      value = {
        description = "ACME certificate ${cert.certName}";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        before = mkIf (cert.reload != null) [ cert.reload ];
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.webroot}";
          ExecStart = let
            certbotArgs = cert: [
              "certonly"
              "--non-interactive"
              "--agree-tos"
              "--email" "clement@dubreuil.dev"
              "--keep-until-expiring"
              "--renew-with-new-domains"
              "--config-dir" cfg.directory
              "--webroot"
              "-w" cfg.webroot
              "--preferred-profile" cert.profile
              "--key-type" "ecdsa"
              "--cert-name" cert.certName
            ]
            ++ concatMap (domain: [ "-d" domain ]) cert.domains
            ++ optionals (cert.reload != null) [
              "--deploy-hook" (pkgs.writeShellScript "deploy-${utils.escapeSystemdPath name}" ''
                set -e
                ${pkgs.coreutils}/bin/chmod 755 ${escapeShellArg "${cfg.directory}"} ${escapeShellArg "${cfg.directory}/live"} ${escapeShellArg "${cfg.directory}/archive"}
                ${pkgs.coreutils}/bin/chown -R "${cert.user}:${cert.group}" ${escapeShellArg "${cfg.directory}/live/${cert.certName}"} ${escapeShellArg "${cfg.directory}/archive/${cert.certName}"}
                ${pkgs.coreutils}/bin/chmod -R u=rwX,g=rX,o= ${escapeShellArg "${cfg.directory}/live/${cert.certName}"} ${escapeShellArg "${cfg.directory}/archive/${cert.certName}"}
                ${pkgs.systemd}/bin/systemctl try-reload-or-restart ${cert.reload}
              '')
            ];
          in "${pkgs.certbot}/bin/certbot ${escapeShellArgs (certbotArgs cert)}";
        };
      };
    }) cfg.certificates;

    systemd.timers = attrsets.mapAttrs' (name: cert: {
      name = "acme-${utils.escapeSystemdPath name}";
      value = {
        description = "ACME certificate ${cert.certName}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "1h";
          Persistent = true;
        };
      };
    }) cfg.certificates;
  };
}
