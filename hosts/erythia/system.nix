{ lib, pkgs, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0";

  systemd.network = {
    networks."10-ens3" = {
      matchConfig.Name = "ens3";
      networkConfig = {
        DHCP = "ipv4";
        Address = ["2001:41d0:305:2100::dd40/128"];
        Gateway = ["2001:41d0:305:2100::1/64"];
        IPv6AcceptRA = false;
      };
    };
  };

  system.stateVersion = "26.05";
}
