{ ... }:
{
  imports = [
    ../../system/base.nix
    ../../system/docker.nix
    ../../system/i3.nix
  ];

  networking.hostName = "alfeto";

  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/7614576f-69a6-4767-9418-47e599d2bc5f";
  };

  networking.wireless.iwd.enable = true;
  networking.useDHCP = false; # handled by systemd
  systemd.network = {
    enable = true;
    networks."10-wlan0" = {
      matchConfig.Name = "wlan0";
      networkConfig.DHCP = "yes";
    };
  };

  system.stateVersion = "23.05";
}
