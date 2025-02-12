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
        Address = "2a01:4f8:c013:578a::1/64";
        Gateway = "fe80::1";
      };
    };

    networks."10-enp7s0" = {
      matchConfig.Name = "enp7s0";
      networkConfig.DHCP = "ipv4";
    };
  };

  services.postgresql = {
    enable = true;
    enableJIT = true;
    package = pkgs.postgresql_16;
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser    address  auth-method
      local  all       postgres           peer
    '';
  };

  system.stateVersion = "24.05";
}
