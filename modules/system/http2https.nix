{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.http2https;
in {
  options.clement.http2https = {
    enable = mkEnableOption "http2https";
  };

  config = mkIf cfg.enable {
    systemd.services.http2https = {
      description = "http to https service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.proxy64}/bin/proxy64 http2https";
        Restart = "on-failure";

        DynamicUser = true;
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        NoNewPrivileges = true;
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
  };
}
