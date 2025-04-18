{ lib, ... }:
{
  clement.profile.router.enable = true;
  clement.profile.edge-router.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";

  systemd.network = {
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
        IPv6AcceptRA = false;
      };
    };
  };

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  clement.profile.router.bird.config = ./bird.conf;
  clement.profile.router.bgp.allowedIp = [
    "2a0c:b640:8::ffff" # Servperso
  ];

  clement.mesh = {
    secretsFile = ./secrets.json;
    address = "fd34:ad42:6ef8::3";
    port = 57205;
  };

  system.stateVersion = "23.11";
}
