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

    postgresql.enable = mkOption {
      type = types.bool;
      default = config.services.postgresql.enable;
    };

    commands = mkOption {
      type = types.attrsOf types.lines;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    clement.restic.commands.postgresql = mkIf cfg.postgresql.enable (mkDefault ''
      ${pkgs.util-linux}/bin/runuser --user postgres -- \
        ${config.services.postgresql.package}/bin/psql \
        --dbname=postgres \
        --no-align \
        --no-psqlrc \
        --tuples-only \
        --record-separator-zero \
        --set=ON_ERROR_STOP=1 \
        --command="SELECT datname FROM pg_database WHERE datallowconn AND NOT datistemplate AND datname != 'postgres' ORDER BY datname" |
        while IFS= read -r -d "" database; do
          ${pkgs.restic}/bin/restic backup \
            --stdin-from-command \
            --stdin-filename="$database.dump" \
            --tag=postgresql \
            -- \
            ${pkgs.util-linux}/bin/runuser --user postgres -- \
            ${config.services.postgresql.package}/bin/pg_dump \
              --dbname="$database" \
              --format=custom \
              --compress=zstd \
              --no-password
        done
    '');

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
