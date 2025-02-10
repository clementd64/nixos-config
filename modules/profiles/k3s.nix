{ config, lib, pkgs, ... }:

let
  cfg = config.clement.profile.k3s;

in with lib; {
  options.clement.profile.k3s = {
    enable = mkEnableOption "profile k3s";
  };

  config = mkIf cfg.enable {
    clement.k3s = {
      enable = true;
      role = "server";
      config = {
        disable = [ "servicelb" "traefik" "local-storage" ];
        disable-helm-controller = true;
        disable-kube-proxy = true;
        disable-network-policy = true;
        flannel-backend = "none";
        secrets-encryption = true;

        cluster-cidr = "10.42.0.0/16,2a01:4f8:c17:aad::1:0/116";
        service-cidr = "10.43.0.0/16,fd62:ec16:d507:1af6::/112";
        kube-controller-manager-arg = "node-cidr-mask-size-ipv6=116";
      };
    };

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -s 10.42.0.0/16 -p tcp -m multiport --dports 6443,10250 -j ACCEPT
      ip6tables -A nixos-fw -s 2a01:4f8:c17:aad::1:0/116 -p tcp -m multiport --dports 6443,10250 -j ACCEPT
    '';
  };
}
