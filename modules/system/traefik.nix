{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.traefik;
  settingsFormat = pkgs.formats.json {};

  staticConfigFile = settingsFormat.generate "config.json" cfg.config;
  dynamicConfigFile = settingsFormat.generate "dynamic.json" cfg.dynamic;
in {
  options.clement.traefik = {
    enable = mkEnableOption "traefik";
    enableDocker = mkOption {
      type = types.bool;
      default = true;
    };

    config = mkOption {
      type = settingsFormat.type;
      default = {};
    };

    dynamic = mkOption {
      type = types.nullOr settingsFormat.type;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    clement.traefik.config.providers = {
      docker = mkIf (config.clement.docker.enable && cfg.enableDocker) {};
      file = mkIf (cfg.dynamic != null) {
        filename = dynamicConfigFile;
      };
    };

    systemd.services.traefik = {
      description = "Traefik service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.traefik}/bin/traefik --configfile=${staticConfigFile}";
        Restart = "on-failure";

        User = "traefik";
        Group = "traefik";
        SupplementaryGroups = mkIf (config.clement.docker.enable && cfg.enableDocker) "docker";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        NoNewPrivileges = true;
        LimitNPROC = 64;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        DevicePolicy = "closed";
        ProtectProc = "invisible";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
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
    };

    users.users.traefik = {
      group = "traefik";
      isSystemUser = true;
    };
    users.groups.traefik = {};

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
