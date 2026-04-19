{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.profile.as212625;
in {
  options.clement.profile.as212625 = {
    enable = mkEnableOption "profile as212625";

    dns.bind = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    dns.resolver.listen = mkOption {
      type = types.listOf types.attrs;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    clement.profile.router.enable = true;

    clement.nat64 = {
      enable = true;
      prefix = "2a0c:b641:2b0::64:0:0/96";
      allowed = [
        "2001:bc8:1640:5d6::/64"
        "2001:bc8:710:1198::/64"
      ];
      dns64 = {
        enable = true;
        address = "2a0c:b641:2b0::64:0:53";
      };
    };

    services.coredns = {
      enable = true;
      config = ''
        as212625.net. {
          bind ${concatStringsSep " " cfg.dns.bind}
          file ${./as212625.net.zone}
        }
      '';
    };

    clement.secrets = {
      "as212625-dns-cert" = {
        file = ./secrets.json;
        extract = ''["dns"]["cert"]'';
        user = "knot-resolver";
        before = [ "knot-resolver.service" ];
      };
      "as212625-dns-key" = {
        file = ./secrets.json;
        extract = ''["dns"]["key"]'';
        user = "knot-resolver";
        before = [ "knot-resolver.service" ];
      };
    };

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
