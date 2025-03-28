{ config, lib, pkgs, ... }:

let
  cfg = config.clement.profile.k3s;

in with lib; {
  options.clement.profile.k3s = {
    enable = mkEnableOption "profile k3s";

    ipv4 = {
      pods = mkOption {
        type = types.str;
        default = "10.42.0.0/16";
      };
      service = mkOption {
        type = types.str;
        default = "10.43.0.0/16";
      };
    };

    ipv6 = {
      pods = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      service = mkOption {
        type = types.str;
        default = "fd62:ec16:d507:1af6::/112";
      };
    };

    san = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    clement.k3s = {
      enable = true;
      role = "server";
      config = {
        disable = [ "servicelb" "traefik" "local-storage" ];
        disable-helm-controller = true;
        flannel-backend = "host-gw";
        secrets-encryption = true;
        tls-san = cfg.san;

        cluster-cidr = cfg.ipv4.pods + optionalString (cfg.ipv6.pods != null) ",${cfg.ipv6.pods}";
        service-cidr = cfg.ipv4.service + optionalString (cfg.ipv6.pods != null) ",${cfg.ipv6.service}";
        kube-controller-manager-arg = mkIf (cfg.ipv6.pods != null) "node-cidr-mask-size-ipv6=116";
      };
    };

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -s ${cfg.ipv4.pods} -p tcp -m multiport --dports 6443,10250 -j ACCEPT
    '' + optionalString (cfg.ipv6.pods != null) ''
      ip6tables -A nixos-fw -s ${cfg.ipv6.pods} -p tcp -m multiport --dports 6443,10250 -j ACCEPT
    '';
  };
}
