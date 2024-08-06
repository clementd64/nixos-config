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
          "194.28.98.82/27"
          "2a0c:b640:8:82::1/48"
        ];
        Gateway = [
          "194.28.98.94"
          "2a0c:b640:8::ffff"
        ];
      };
    };
  };

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  services.bird2 = {
    enable = true;
    config = builtins.readFile ./bird.conf;
  };

  networking.firewall.checkReversePath = false;
  networking.firewall.extraCommands = ''
    ip6tables -A nixos-fw -i ens18 -s 2a0c:b640:8::ffff/128 -p tcp --dport 179 -j ACCEPT
  '';

  system.stateVersion = "23.11";
}
