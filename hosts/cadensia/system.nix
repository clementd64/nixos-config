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
    package = pkgs.postgresql_17;
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser    address                                  auth-method
      local  all       postgres                                           peer
      host   dex       dex       ${config.clement.profile.k3s.ipv4.pods}  scram-sha-256
      host   lldap     lldap     ${config.clement.profile.k3s.ipv4.pods}  scram-sha-256
    '';
  };

  # Open postgresql port for k8s pods
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -s ${config.clement.profile.k3s.ipv4.pods} -p tcp --dport 5432 -j ACCEPT
  '';

  clement.profile.k3s = {
    enable = true;
    san = [ "cadensia.host.segfault.ovh" ];
  };

  clement.http2https.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 6443 ];

  clement.mesh = {
    secretsFile = ./secrets.json;
    address = "fd34:ad42:6ef8::5";
    port = 57205;
  };

  system.stateVersion = "24.11";
}
