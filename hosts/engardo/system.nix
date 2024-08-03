{ lib, pkgs, ... }:
let
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

  cilium-manifests = pkgs.callPackage ../../lib/buildCiliumChart.nix {
    name = "cilium";
    version = "1.16.0";
    digest = "2d653f4826722da976791047f7f3d9e999526590ea4df2f36a3846aedbffae2d";
    values = cilium-values;
  };

in {
  clement.isServer = true;
  imports = [
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;

  networking.useDHCP = false; # handled by systemd
  systemd.network = {
    enable = true;
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2a01:4f8:c17:aad::1/64";
        Gateway = "fe80::1";
      };
    };

    wait-online.anyInterface = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/rancher/k3s"
    ];
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  # Required for kubelet as nspawn can't override it
  boot.kernel.sysctl = {
    "vm.panic_on_oom" = 0;
    "vm.overcommit_memory" = 1;
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;
  };

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

  boot.kernelModules = [ "ip6_tables" "ip6table_mangle" "ip6table_raw" "ip6table_filter" ];
  networking.firewall.checkReversePath = false;
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -s 10.42.0.0/16 -p tcp -m multiport --dports 6443,10250 -j ACCEPT
    ip6tables -A nixos-fw -s 2a01:4f8:c17:aad::1:0/116 -p tcp -m multiport --dports 6443,10250 -j ACCEPT
  '';

  environment.systemPackages = [
    pkgs.k3s
    (pkgs.writeShellScriptBin "kubectl" "exec -a $0 ${pkgs.k3s}/bin/k3s $@")
  ];

  system.stateVersion = "23.11";
}
