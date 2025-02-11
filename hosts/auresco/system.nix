{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;
  imports = [
    ./hardware.nix
  ];

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

  system.stateVersion = "24.11";
}
