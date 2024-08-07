{ config, lib, pkgs, utils, ... }:

with lib; let
  cfg = config.clement.profile.router;

  mkFamilyMap = map: family: map.${family} or (throw "unknown family: ${family}");

  iptables = mkFamilyMap { "ipv4" = "iptables"; "ipv6" = "ip6tables"; };
  inet = mkFamilyMap { "ipv4" = "inet"; "ipv6" = "inet6"; };

  mkBgpAllowRule = family: allowedIp: if builtins.length allowedIp == 0 then "" else ''
    ipset create bgp_allowed_${family} hash:ip family ${inet family}
    ${lib.concatMapStrings (ip: "ipset add bgp_allowed_${family} ${ip}\n") allowedIp}
    ${iptables family} -A nixos-fw -m set --match-set bgp_allowed_${family} src -p tcp --dport 179 -j ACCEPT
  '';
in {
  options.clement.profile.router = {
    enable = mkEnableOption "router profile";

    bird.config = mkOption {
      type = types.path;
      description = "Bird configuration";
    };

    bgpAllowedIPv4 = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of allowed BGP peers";
    };

    bgpAllowedIPv6 = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of allowed BGP peers";
    };
  };

  config = mkIf cfg.enable {
    clement.profile.server.enable = true;

    networking.firewall = {
      checkReversePath = false;
      extraPackages = [ pkgs.ipset ];
      extraCommands = ''
        ipset destroy
        ${mkBgpAllowRule "ipv4" cfg.bgpAllowedIPv4}
        ${mkBgpAllowRule "ipv6" cfg.bgpAllowedIPv6}
      '';
    };

    services.bird2 = {
      enable = true;
      config = strings.concatMapStringsSep "\n" (x: builtins.readFile x) [
        ./common.conf
        cfg.bird.config
      ];
    };

    boot.kernel.sysctl = {
      "net.ipv6.conf.all.autoconf" = "0";
      "net.ipv6.conf.all.accept_ra" = "0";
    };

    systemd.network.config.networkConfig = {
      ManageForeignRoutes = false;
    };
  };
}
