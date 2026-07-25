{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-ens2" = {
      matchConfig.Name = "ens2";
      networkConfig = {
        DHCP = "ipv6";
        IPv6PrivacyExtensions = false;
      };
      ipv6AcceptRAConfig = {
        Token = "eui64";
        UseDNS = "no";
      };
    };
  };

  clement.profile.patroni = {
    enable = true;
    secretsFile = ./secrets.json;
  };

  swapDevices = [ {
    device = "/nix/swap";
    size = 2*1024;
  } ];

  system.stateVersion = "25.11";
}
