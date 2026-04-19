{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.profile.router;
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

  config = mkIf cfg.enable {
    clement.profile.server.enable = true;

    clement.firewall.src."tcp:179" = cfg.bgp.allowedIp;
    networking.firewall.checkReversePath = false;

    services.bird = {
      enable = true;
      config = strings.concatMapStringsSep "\n" (x: builtins.readFile x) [
        ./common.conf
        cfg.bird.config
      ];
    };

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = "1";
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
