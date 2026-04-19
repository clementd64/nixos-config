{ lib, ... }:
{
  clement.profile.as212625.enable = true;

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

  clement.dummy.dum0.addresses = [ "2a0c:b641:2b2::1/128" ];
  clement.dummy.dns-rec.addresses = [ "2a0c:b641:2b2::53/128" ];

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  clement.profile.router.bird.config = ./bird.conf;
  clement.profile.router.bgp.allowedIp = [
    "2a0c:b640:8::ffff" # Servperso
  ];
  clement.profile.as212625.dns.bind = [
    "194.28.98.82"
    "2a0c:b641:2b2::1"
  ];
  clement.profile.as212625.dns.resolver.listen = [
    { interface = "194.28.98.82"; kind = "dot"; }
    { interface = "2a0c:b641:2b2::53"; kind = "dot"; }
    { interface = "2a0c:b641:2b2::53"; kind = "dns"; }
  ];

  clement.wireguard = {
    home = {
      addresses = [ "fe80::1/64" ];
      port = 51820;
      presharedKey = ''["wireguard"]["home"]["preshared-key"]'';
      privateKey = ''["wireguard"]["home"]["private-key"]'';
      publicKey = "fL2bCOcZFXJeUtE4372q1URCIToWgj0H0qkyTDIv0Qc=";
      secretsFile = ./secrets.json;
    };
    pixel = {
      addresses = [ "fe80::1/64" ];
      allowedIps = [ "2a0c:b641:2b2::9/128" "194.28.98.113/32" ];
      port = 51821;
      presharedKey = ''["wireguard"]["pixel"]["preshared-key"]'';
      privateKey = ''["wireguard"]["pixel"]["private-key"]'';
      publicKey = "Q7mUDHH4ksk/2BCQHIWso94JIvX+BcQJQhs+qluBIyI=";
      secretsFile = ./secrets.json;
    };
  };

  system.stateVersion = "23.11";
}
