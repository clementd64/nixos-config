{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.nat64;
in {
  options.clement.nat64 = {
    enable = mkEnableOption "nat64";
    prefix = mkOption {
      type = types.str;
      default = "64:ff9b::/96";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nat64 = {
      description = "NAT64 service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStartPre = "${pkgs.iptables}/bin/ip6tables -t mangle -A PREROUTING -d ${cfg.prefix} -p tcp -j TPROXY --on-port=1337 --on-ip=::1";
        ExecStopPost = "${pkgs.iptables}/bin/ip6tables -t mangle -D PREROUTING -d ${cfg.prefix} -p tcp -j TPROXY --on-port=1337 --on-ip=::1";
        ExecStart = "${pkgs.proxy64}/bin/proxy64 nat64";
        Restart = "on-failure";

        DynamicUser = true;
        AmbientCapabilities = "CAP_NET_ADMIN";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
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

    systemd.network = {
      networks."30-nat64" = {
        matchConfig.Name = "lo";
        # TODO(24.11): cleanup
        routes = [
          (if versionAtLeast config.system.nixos.release "24.11"
          then { Type = "local"; Destination = cfg.prefix; }
          else { routeConfig = { Type = "local"; Destination = cfg.prefix; }; })
        ];
      };
    };
  };
}
