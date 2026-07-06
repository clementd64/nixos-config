{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-ens2" = {
      matchConfig.Name = "ens2";
      networkConfig = {
        DHCP = true;
        DNS = "2a0c:b641:2b0::64:0:53#dns64.as212625.net";
        DNSOverTLS = true;
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
