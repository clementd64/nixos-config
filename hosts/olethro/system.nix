{ pkgs, lib, ... }:
{
  clement.profile.server.enable = true;
  imports = [
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-enp0s6" = {
      matchConfig.Name = "enp0s6";
      networkConfig.DHCP = "yes";
    };
  };

  system.stateVersion = "24.05";
}
