{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.nat64;
  allowedRule = pkgs.net.ipsetRule {
    name = "nat64-allowed";
    type = "hash:net";
    family = "ipv6";
    set = cfg.allowed;
    rules = { iptables, ipset }: ''
      ${iptables} -A nixos-fw -d ${cfg.prefix} -p tcp -m set --match-set ${ipset} src -j ACCEPT
    '' + optionalString cfg.dns64.enable ''
      ${iptables} -A nixos-fw -d ${cfg.dns64.address} -p udp --dport 53 -m set --match-set ${ipset} src -j ACCEPT
    '';
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
      resolvers = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      tlsServerName = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nat64 = {
      description = "NAT64 service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      protect = {
        enable = true;
        memoryExec = true;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.proxy64}/bin/proxy64 nat64";
        Restart = "on-failure";

        AmbientCapabilities = "CAP_NET_ADMIN";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
      };
    };

    systemd.network = {
      networks."30-nat64" = {
        matchConfig.Name = "lo";
        routes = [{ Type = "local"; Destination = cfg.prefix; }];
      };
    };

    clement.dummy.dns64 = mkIf cfg.dns64.enable {
      addresses = [ "${cfg.dns64.address}/128" ];
    };

    networking.ipset = allowedRule.ipset;
    networking.firewall.extraCommands = allowedRule.extraCommands + ''
      # Clean up nat64 rules
      ip6tables -t mangle -D PREROUTING -j nat64 2> /dev/null || true
      ip6tables -t mangle -F nat64 2> /dev/null || true
      ip6tables -t mangle -X nat64 2> /dev/null || true

      # Set up nat64 rules
      ip6tables -t mangle -N nat64 2> /dev/null || true
      ip6tables -t mangle -A nat64 -d ${cfg.prefix} -p tcp -j TPROXY --on-port=1337 --on-ip=::1
      ip6tables -t mangle -A PREROUTING -j nat64
    '';

    networking.firewall.extraStopCommands = ''
      ip6tables -t mangle -D PREROUTING -j nat64 2>/dev/null || true
    '';
    services.coredns = mkIf cfg.dns64.enable {
      enable = true;
      config = ''
        . {
          bind ${cfg.dns64.address}
          forward . ${concatStringsSep " " cfg.dns64.resolvers} {
            ${optionalString (cfg.dns64.tlsServerName != null) "tls_servername ${cfg.dns64.tlsServerName}"}
          }
          dns64 {
            prefix ${cfg.prefix}
          }
          errors
          loop
          nsid ${config.networking.hostName}
        }
      '';
    };
  };
}
