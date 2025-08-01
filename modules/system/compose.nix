{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.compose;
in {
  options.clement.compose = {
    enable = mkEnableOption "compose";

    config  = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.compose = {
      description = "compose service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = let
        start = [
          "${pkgs.docker-compose}/bin/docker-compose -f ${cfg.config} pull"
          "${pkgs.docker-compose}/bin/docker-compose -f ${cfg.config} up -d"
        ];
      in {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = start;
        ExecReload = start;
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${cfg.config} down";
        Restart = "on-failure";

        User = "clement";
        NoNewPrivileges = true;
        PrivateTmp = true;
        DevicePolicy = "closed";
        ProtectProc = "invisible";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        LockPersonality = true;
      };
      environment = {
        COMPOSE_PROJECT_NAME = "compose";
      };
    };
  };
}
