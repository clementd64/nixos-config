{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.profile.as212625;
  dnsRule = pkgs.net.ipsetRules {
    name = "as212625-dns";
    type = "hash:ip";
    set = cfg.dns.bind;
    rules = { iptables, ipset }: ''
      ${iptables} -A nixos-fw -p tcp --dport 53 -m set --match-set ${ipset} dst -j ACCEPT
      ${iptables} -A nixos-fw -p udp --dport 53 -m set --match-set ${ipset} dst -j ACCEPT
    '';
  };
in {
  options.clement.profile.as212625 = {
    enable = mkEnableOption "profile as212625";

    dns.bind = mkOption {
      type = types.listOf types.str;
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

    networking.ipset = dnsRule.ipset;
    networking.firewall.extraCommands = dnsRule.extraCommands;
  };
}
