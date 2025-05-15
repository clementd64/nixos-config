{ config, lib, pkgs, utils, ... }:

with lib; let
  cfg = config.clement.profile.router;

  mkBgpAllowRule = family: allowedIp:
    { ... }: mkIf (cfg.enable && builtins.length allowedIp > 0) {
    networking.ipset."bgp-allowed-${family}" = {
      inherit family;
      type = "hash:ip";
      set = allowedIp;
    };

    networking.firewall.extraCommands = ''
      ${{ "ipv4" = "iptables"; "ipv6" = "ip6tables"; }.${family}} -A nixos-fw -m set --match-set ${config.networking.ipset."bgp-allowed-${family}".name} src -p tcp --dport 179 -j ACCEPT
    '';
  };
in {
  options.clement.profile.router = {
    enable = mkEnableOption "router profile";

    bird.config = mkOption {
      type = types.path;
      description = "Bird configuration";
    };

    bgp.allowedIp = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of allowed BGP peers";
    };
  };

  imports = [
    (mkBgpAllowRule "ipv4" (pkgs.net.filterIPv4 cfg.bgp.allowedIp))
    (mkBgpAllowRule "ipv6" (pkgs.net.filterIPv6 cfg.bgp.allowedIp))
  ];

  config = mkIf cfg.enable {
    clement.profile.server.enable = true;

    networking.firewall.checkReversePath = false;

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
      "net.ipv6.conf.all.forwarding" = "1";
    };

    services.resolved.llmnr = "false";
    systemd.network.config.networkConfig = {
      ManageForeignRoutes = false;
    };
  };
}
