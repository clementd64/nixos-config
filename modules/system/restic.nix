{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.restic;
in
{
  options.clement.restic = {
    enable = mkOption {
      type = types.bool;
      default = cfg.secrets.file != null;
    };

    secrets = {
      file = mkOption {
        type = types.nullOr types.path;
        default = null;
      };

      extract = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };

    postgresql = {
      enable = mkOption {
        type = types.bool;
        default = config.services.postgresql.enable;
      };

      databases = mkOption {
        type = types.attrsOf (types.submodule {
          options.exclude-table-data = mkOption {
            type = types.listOf types.str;
            default = [];
          };
        });
        default = {};
      };
    };

    commands = mkOption {
      type = types.attrsOf types.lines;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    clement.restic.commands.postgresql = mkIf cfg.postgresql.enable (mkDefault
      (concatStringsSep "\n" (mapAttrsToList (database: options: ''
        ${pkgs.restic}/bin/restic backup \
          --stdin-from-command \
          --stdin-filename=${escapeShellArg "${database}.dump"} \
          --tag=postgresql \
          -- \
          ${pkgs.util-linux}/bin/runuser --user postgres -- \
          ${config.services.postgresql.package}/bin/pg_dump \
            --dbname=${escapeShellArg database} \
            --format=custom \
            --compress=zstd \
            --no-password \
            ${escapeShellArgs (map (table: "--exclude-table-data=${table}") options.exclude-table-data)}
      '') cfg.postgresql.databases)));

    clement.secrets.restic = {
      file = cfg.secrets.file;
      extract = cfg.secrets.extract;
      format = "dotenv";
      mode = "0400";
      before = [ "restic-backup.service" ];
    };

    systemd.services.restic-backup = {
      description = "Restic backup";
      wants = [ "network-online.target" ];
      requires = optional cfg.postgresql.enable "postgresql.service";
      after = [ "network-online.target" ]
        ++ optional cfg.postgresql.enable "postgresql.service";
      protect = {
        enable = true;
        memoryExec = true;
      };
      environment.RESTIC_CACHE_DIR = "%C/restic-backup";
      path = [ pkgs.restic ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        AmbientCapabilities = [ "CAP_SETUID" "CAP_SETGID" ];
        ExecStart = pkgs.writeShellScript "restic-backup" ''
          set -euo pipefail
          ${concatMapStringsSep "\n" (name: ''
            (
              ${cfg.commands.${name}}
            )
          '') (attrNames cfg.commands)}
          ${pkgs.restic}/bin/restic forget --prune \
            --keep-hourly 24 \
            --keep-daily 30 \
            --keep-weekly 4 \
            --keep-monthly 12 \
            --keep-yearly 2
        '';
        EnvironmentFile = config.clement.secrets.restic.path;
        CacheDirectory = "restic-backup";
        CacheDirectoryMode = "0700";
        PrivateTmp = true;
      };
    };

    systemd.timers.restic-backup = {
      description = "Restic backup";
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "hourly";
    };
  };
}
