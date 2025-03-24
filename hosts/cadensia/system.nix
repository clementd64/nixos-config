{ lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [
    "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA61620654480FGN"
    "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA634507N9480FGN"
  ];

  systemd.network = {
    networks."10-eno1" = {
      matchConfig.Name = "eno1";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2001:41d0:2:9ed3::1/56";
        Gateway = "2001:41d0:2:9eff:ff:ff:ff:ff";
      };
    };
  };

  clement.docker.enable = true;

  system.stateVersion = "24.11";
}
