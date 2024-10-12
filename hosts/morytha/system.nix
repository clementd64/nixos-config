{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;
  imports = [
    ./hardware.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_53265838";

  systemd.network = {
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2a01:4f8:c17:9510::1/64";
        Gateway = "fe80::1";
      };
    };
  };

  clement.factorio = {
    enable = true;
    savePath = "/var/lib/factorio/test.zip";
    serverSettings = {
      name = "";
      description = "";
      visibility = {
        public = false;
        lan = false;
      };
      require_user_verification = true;
    };
    whitelist = [ "Ashuta" ];
    adminlist = [ "Ashuta" ];
  };

  system.stateVersion = "24.05";
}
