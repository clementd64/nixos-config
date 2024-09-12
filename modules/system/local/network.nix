{ config, lib, pkgs, ... }:

let cfg = config.clement.local.network;
in with lib; {
  options.clement.local.network = {
    enable = mkEnableOption "local network";
    ipv4 = mkOption {
      type = types.str;
      default = "192.168.192.168";
    };
    ipv6 = mkOption {
      type = types.str;
      default = "fd55:d249:5b9d:4dce:64fd:f7c3:cf53:9905";
    };
    resolved.enable = mkEnableOption "resolved extra listener";
  };

  config = mkIf cfg.enable {
    systemd.network = {
      netdevs."20-local" = {
        netdevConfig = {
          Name = "local";
          Kind = "dummy";
        };
      };

      networks."20-local" = {
        matchConfig.Name = "local";
        networkConfig = {
          Address = [
            "${cfg.ipv4}/32"
            "${cfg.ipv6}/128"
          ];
        };
      };
    };

    networking.firewall.extraCommands = concatStringsSep "\n" ([]
      ++ optional config.clement.docker.enable "iptables -A nixos-fw -s ${config.clement.docker.pools.ipv4.subnet} -d ${cfg.ipv4} -j ACCEPT"
      ++ optional (config.clement.docker.enable && config.clement.docker.pools.ipv6.subnet != null) "ip6tables -A nixos-fw -s ${config.clement.docker.pools.ipv6.subnet} -d ${cfg.ipv6} -j ACCEPT"
    );

    services.resolved.extraConfig = mkIf cfg.resolved.enable ''
      DNSStubListenerExtra=${cfg.ipv4}
      DNSStubListenerExtra=${cfg.ipv6}
    '';
  };
}
