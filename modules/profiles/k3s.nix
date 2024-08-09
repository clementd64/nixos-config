{ config, lib, pkgs, ... }:

let
  cfg = config.clement.profile.k3s;

  cilium-values = {
    ipam.mode = "kubernetes";

    # kube proxy replacement
    kubeProxyReplacement = true;
    k8sServiceHost = "127.0.0.1";
    k8sServicePort = 6443;
    routingMode = "native";
    ipv4NativeRoutingCIDR = "10.42.0.0/16";

    ipv4.enabled = true;
    enableIPv4Masquerade = true;
    ipv6.enabled = true;
    enableIPv6Masquerade = false;
    bpf.masquerade = true;

    operator.replicas = 1;

    hubble.enabled = false;
  };

  cilium-manifests = pkgs.buildCiliumChart {
    name = "cilium";
    version = "1.16.0";
    digest = "2d653f4826722da976791047f7f3d9e999526590ea4df2f36a3846aedbffae2d";
    values = cilium-values;
  };

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
      manifests.cilium = cilium-manifests;
    };


    # Required for cilium IPv6
    boot.kernelModules = [ "ip6_tables" "ip6table_mangle" "ip6table_raw" "ip6table_filter" ];
    # Cilium use asymesmetric routing. rp_filter can still be enabled per interface with sysctl
    networking.firewall.checkReversePath = false;

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -s 10.42.0.0/16 -p tcp -m multiport --dports 6443,10250 -j ACCEPT
      ip6tables -A nixos-fw -s 2a01:4f8:c17:aad::1:0/116 -p tcp -m multiport --dports 6443,10250 -j ACCEPT
    '';
  };
}
