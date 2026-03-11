{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  systemd.network = {
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2a01:4f8:c17:1552::1/64";
        Gateway = "fe80::1";
      };
    };

    networks."10-enp7s0" = {
      matchConfig.Name = "enp7s0";
      networkConfig.DHCP = "ipv4";
    };
  };

  system.stateVersion = "25.11";
}