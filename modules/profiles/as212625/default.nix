{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.profile.as212625;
in {
  options.clement.profile.as212625 = {
    enable = mkEnableOption "profile as212625";

    dns = {
      primary = mkEnableOption "primary";
      bind = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };

    dns.resolver.listen = mkOption {
      type = types.listOf types.attrs;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    clement.profile.router.enable = true;

    clement.local.addresses = [ "2a0c:b641:2b0::1/128" "62.3.50.46/32" ];
    clement.profile.as212625.dns.resolver.listen = [
      { interface = "2a0c:b641:2b0::1"; kind = "dot"; }
      { interface = "62.3.50.46"; kind = "dot"; }
    ];

    clement.proxy64 = {
      nat64 = {
        enable = true;
        prefix = "2a0c:b641:2b0::64:0:0/96";
        allowed = [
          "2001:bc8:1640:5d6::/64"
          "2001:bc8:710:1198::/64"
        ];
        dns64 = {
          enable = true;
          address = "2a0c:b641:2b0::64:0:53";
          resolvers = map (value: "tls://${value.interface}") (builtins.filter (value: value.kind == "dot") cfg.dns.resolver.listen);
          tlsServerName = "dns.as212625.net";
          certFile = config.clement.secrets."as212625-dns-cert".path;
          keyFile = config.clement.secrets."as212625-dns-key".path;
        };
      };
    };

    services.coredns = {
      enable = true;
      config = ''
        as212625.net. {
          bind ${concatStringsSep " " cfg.dns.bind}
          file ${../../../dns/zones/as212625.net.zone}
        }
        b.2.0.1.4.6.b.c.0.a.2.ip6.arpa. {
          bind ${concatStringsSep " " cfg.dns.bind}
          file ${../../../dns/zones/b.2.0.1.4.6.b.c.0.a.2.ip6.arpa.zone}
        }
        dubreuil.dev. {
          bind ${concatStringsSep " " cfg.dns.bind}
          file ${../../../dns/zones/dubreuil.dev.zone}
        }
      '';
    };

    clement.secrets = {
      "as212625-dns-cert" = {
        file = ./secrets.json;
        extract = ''["dns"]["cert"]'';
        group = "dns";
        before = [ "knot-resolver.service" "coredns.service" ];
      };
      "as212625-dns-key" = {
        file = ./secrets.json;
        extract = ''["dns"]["key"]'';
        group = "dns";
        before = [ "knot-resolver.service" "coredns.service" ];
      };
    };

    users.groups.dns = {};
    systemd.services.coredns.serviceConfig.SupplementaryGroups = [ "dns" ];
    systemd.services.knot-resolver.serviceConfig.SupplementaryGroups = [ "dns" ];

    services.knot-resolver = {
      enable = true;
      settings = {
        network = {
          listen = cfg.dns.resolver.listen;
          tls = {
            cert-file = config.clement.secrets."as212625-dns-cert".path;
            key-file = config.clement.secrets."as212625-dns-key".path;
          };
        };
        management.interface = "::1@5000";
        dnssec.log-bogus = true;
        nsid = config.networking.hostName;
      };
    };

    clement.firewall.dst = {
      "udp:53" = cfg.dns.bind;
      "tcp:53" = cfg.dns.bind;
      "tcp:853" = map (value: value.interface) (builtins.filter (value: value.kind == "dot") cfg.dns.resolver.listen);
    };
  };
}
