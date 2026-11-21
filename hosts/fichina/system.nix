{ pkgs, lib, ... }:
{
  clement.profile.server.enable = true;
  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        Address = [ "2a01:4f9:c015:2455::1/64" ];
        Gateway = "fe80::1";
      };
    };
  };

  system.stateVersion = "26.05";
}
