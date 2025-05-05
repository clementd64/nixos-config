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

  clement.wireguard.cadensia = {
    secretsFile = ./secrets.json;
    privateKey = ''["cadensia"]["private-key"]'';
    publicKey = "ZF4I42A615HDEFROsxZXc9fhxIoIVZkBp0UrC3osSFU=";
    port = 57206;
    addresses = ["fe80::1/64"];
    allowedIps = ["::/0"];
    endpoint = "[2001:41d0:2:9ed3::1]:57206";
  };

  system.stateVersion = "23.11";
}
