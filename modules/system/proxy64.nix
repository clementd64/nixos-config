{ config, lib, pkgs, ... }:

with lib; let
  nat64 = config.clement.proxy64.nat64;
  sni = config.clement.proxy64.sni;
  http2https = config.clement.proxy64.http2https;

  allowedRule = pkgs.net.ipsetRule {
    name = "nat64-allowed";
    type = "hash:net";
    family = "ipv6";
    set = nat64.allowed;
    rules = { iptables, ipset }: ''
      ${iptables} -A nixos-fw -d ${nat64.prefix} -p tcp -m set --match-set ${ipset} src -j ACCEPT
    '' + optionalString nat64.dns64.enable ''
      ${iptables} -A nixos-fw -d ${nat64.dns64.address} -p udp --dport 53 -m set --match-set ${ipset} src -j ACCEPT
    '';
  };

  enable = nat64.enable || sni.enable || http2https.enable;
in {
  options.clement.proxy64 = {
    nat64 = {
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

    sni = {
      enable = mkEnableOption "sni";
      listen = mkOption {
        type = types.str;
        default = ":443";
      };
      prefix = mkOption {
        type = types.str;
      };
      allowed = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };

    http2https = {
      enable = mkEnableOption "http2https";
      listen = mkOption {
        type = types.str;
        default = ":80";
      };
    };
  };

  config = {
    systemd.services.proxy64 = mkIf enable {
      description = "proxy64 service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      protect = {
        enable = true;
        memoryExec = true;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.proxy64}/bin/proxy64";
        Restart = "on-failure";

        AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
      };
      environment = {
        NAT64_PORT = mkIf nat64.enable "1337";
        HTTP2HTTPS_LISTEN = mkIf http2https.enable http2https.listen;
        SNI_LISTEN = mkIf sni.enable sni.listen;
        SNI_PREFIX = mkIf sni.enable sni.prefix;
        SNI_ALLOWED_CIDRS = mkIf sni.enable (concatStringsSep "," sni.allowed);
      };
    };

    # NAT64

    systemd.network.networks."30-nat64" = mkIf nat64.enable {
      matchConfig.Name = "lo";
      routes = [{ Type = "local"; Destination = nat64.prefix; }];
    };

    networking.ipset = mkIf nat64.enable allowedRule.ipset;
    networking.firewall.extraCommands = mkIf nat64.enable (allowedRule.extraCommands + ''
      # Clean up nat64 rules
      ip6tables -t mangle -D PREROUTING -j nat64 2> /dev/null || true
      ip6tables -t mangle -F nat64 2> /dev/null || true
      ip6tables -t mangle -X nat64 2> /dev/null || true

      # Set up nat64 rules
      ip6tables -t mangle -N nat64 2> /dev/null || true
      ip6tables -t mangle -A nat64 -d ${nat64.prefix} -p tcp -j TPROXY --on-port=1337 --on-ip=::1
      ip6tables -t mangle -A PREROUTING -j nat64
    '');

    networking.firewall.extraStopCommands = mkIf nat64.enable ''
      ip6tables -t mangle -D PREROUTING -j nat64 2>/dev/null || true
    '';

    # DNS64

    clement.dummy.dns64 = mkIf nat64.dns64.enable {
      addresses = [ "${nat64.dns64.address}/128" ];
    };

    services.coredns = mkIf nat64.dns64.enable {
      enable = true;
      config = ''
        . {
          bind ${nat64.dns64.address}
          forward . ${concatStringsSep " " nat64.dns64.resolvers} {
            ${optionalString (nat64.dns64.tlsServerName != null) "tls_servername ${nat64.dns64.tlsServerName}"}
          }
          dns64 {
            prefix ${nat64.prefix}
          }
          errors
          loop
          nsid ${config.networking.hostName}
        }
      '';
    };

    ## SNI

    systemd.network.networks."30-sni" = mkIf sni.enable {
      matchConfig.Name = "lo";
      routes = [{ Type = "local"; Destination = sni.prefix; }];
    };
  };
}
