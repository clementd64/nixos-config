{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.nat64;
  allowedRule = pkgs.net.ipsetRule {
    name = "nat64-allowed";
    type = "hash:net";
    family = "ipv6";
    set = cfg.allowed;
    rules = { iptables, ipset }: mkMerge [
      ''${iptables} -A nixos-fw -d ${cfg.prefix} -p tcp -m set --match-set ${ipset} src -j ACCEPT''
      (mkIf cfg.dns64.enable ''
        ${iptables} -A nixos-fw -d ${cfg.dns64.address} -p udp --dport 53 -m set --match-set ${ipset} src -j ACCEPT
      '')
    ];
  };
in {
  options.clement.nat64 = {
    enable = mkEnableOption "nat64";
    prefix = mkOption {
      type = types.str;
      default = "64:ff9b::/96";
    };
    allowed = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    dns64 = {
      enable = mkEnableOption "dns64";
      address = mkOption {
        type = types.str;
      };
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
        routes = [{ Type = "local"; Destination = cfg.prefix; }];
      };

      netdevs."30-dns64" = mkIf cfg.dns64.enable {
        netdevConfig = {
          Name = "dns64";
          Kind = "dummy";
        };
      };

      networks."30-dns64" = mkIf cfg.dns64.enable {
        matchConfig.Name = "dns64";
        networkConfig = {
          Address = [
            "${cfg.dns64.address}/128"
          ];
        };
      };
    };

    networking.ipset = allowedRule.ipset;
    networking.firewall.extraCommands = allowedRule.extraCommands;

    services.coredns = mkIf cfg.dns64.enable {
      enable = true;
      config = ''
        . {
          bind ${cfg.dns64.address}
          forward . tls://2606:4700:4700::1111 tls://2606:4700:4700::1001 tls://1.1.1.1 tls://1.0.0.1 {
            tls_servername cloudflare-dns.com
          }
          dns64 {
            prefix ${cfg.prefix}
          }
          errors
          loadbalance
          cache
          loop
        }
      '';
    };
  };
}
