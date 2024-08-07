{ lib, ... }:
{
  clement.profile.server.enable = true;
  imports = [
    ./hardware.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";

  systemd.network = {
    networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig = {
        Address = [
          "194.28.99.42/27"
          "2a0c:b640:13:42::1/48"
        ];
        Gateway = [
          "194.28.99.62"
          "2a0c:b640:13::ffff"
        ];
      };
    };
  };

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  system.stateVersion = "23.11";
}
