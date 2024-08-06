{ lib, ... }:
{
  clement.profile.server.enable = true;
  imports = [
    ./hardware.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig = {
        Address = [
          "194.28.98.82/27"
          "2a0c:b640:8:82::1/48"
        ];
        Gateway = [
          "194.28.98.94"
          "2a0c:b640:8::ffff"
        ];
      };
    };

    wait-online.anyInterface = true;
  };

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  system.stateVersion = "23.11";
}
