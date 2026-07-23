{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-ens2" = {
      matchConfig.Name = "ens2";
      networkConfig = {
        DHCP = "ipv6";
      };
      ipv6AcceptRAConfig = {
        UseDNS = "no";
      };
    };
  };

  swapDevices = [ {
    device = "/nix/swap";
    size = 2*1024;
  } ];

  system.stateVersion = "24.05";
}
