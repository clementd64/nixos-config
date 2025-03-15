{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2a01:4f8:c012:79f8::1/64";
        Gateway = "fe80::1";
      };
    };

    networks."10-enp7s0" = {
      matchConfig.Name = "enp7s0";
      networkConfig.DHCP = "ipv4";
    };
  };

  clement.profile.k3s = {
    enable = true;
    ipv6.pods = "2a01:4f8:c012:79f8::1:0/116";
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/rancher/k3s"
    ];
  };

  clement.mesh = {
    secretsFile = ./secrets.json;
    address = "fd34:ad42:6ef8::2";
    port = 57205;
  };

  system.stateVersion = "24.11";
}
