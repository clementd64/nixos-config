{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [
    "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA61620654480FGN"
    "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA634507N9480FGN"
  ];

  systemd.network = {
    networks."10-eno1" = {
      matchConfig.Name = "eno1";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2001:41d0:2:9ed3::1/56";
        Gateway = "2001:41d0:2:9eff:ff:ff:ff:ff";
      };
    };
  };

  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = true;
    package = pkgs.postgresql_18;
    settings.shared_preload_libraries = [ "pg_stat_statements" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser    address        auth-method
      local  all       postgres                 peer
      local  all       alloy                    peer
      host   grafana   grafana   172.16.0.0/16  scram-sha-256
      host   miniflux  miniflux  172.16.0.0/16  scram-sha-256
      host   n8n       n8n       172.16.0.0/16  scram-sha-256
    '';
  };

  clement.k3s = {
    enable = true;
    role = "server";
    config = {
      disable = [ "servicelb" "traefik" "local-storage" ];
      disable-helm-controller = true;
      flannel-backend = "host-gw";
      secrets-encryption = true;
      tls-san = "cadensia.host.segfault.ovh";

      cluster-cidr = "172.16.0.0/16";
      service-cidr = "172.17.0.0/16";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 6443 ];
  clement.firewall.src = {
    "tcp:5432" = [ "172.16.0.0/16" ];
    "tcp:6443" = [ "172.16.0.0/16" ];
    "tcp:10250" = [ "172.16.0.0/16" ];
    "tcp:4317" = [
      "172.16.0.0/16"
      # AS212625
      "2a0c:b641:2b0::/44"
      "194.28.98.112/31"
      # cadensia
      "188.165.211.211/32"
      "2001:41d0:2:9ed3::1/128"
      # flamii
      "194.28.98.82/32"
      "2a0c:b640:8:82::1/128"
      # ekidno
      "194.28.99.42/32"
      "2a0c:b640:13:42::1/128"
      # home
      "109.190.115.157"
      "2001:41d0:fc17:5900::/56"
    ];
  };

  services.alloy.enable = true;
  environment.etc."alloy/config.alloy".source = ./config.alloy;

  system.stateVersion = "25.11";
}
