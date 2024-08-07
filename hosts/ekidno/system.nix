{ lib, ... }:
{
  clement.profile.router.enable = true;
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
        IPv6AcceptRA = "no";
      };
    };

    # LocIX DUS
    networks."10-ens19" = {
      matchConfig.Name = "ens19";
      networkConfig = {
        Address = [
          "185.1.155.60/24"
          "2a0c:b641:701::a5:21:2625:1/64"
        ];
        IPv6AcceptRA = "no";
      };
    };

    # LocIX FRA
    networks."10-ens20" = {
      matchConfig.Name = "ens20";
      networkConfig = {
        Address = [
          "185.1.166.16/23"
          "2001:7f8:f2:e1:a5:21:2625:1/64"
        ];
        IPv6AcceptRA = "no";
      };
    };

    # bgp.exchange
    networks."10-ens21" = {
      matchConfig.Name = "ens21";
      networkConfig = {
        Address = [
          "100.66.181.7/22"
          # "2407:c280:ee:46::107/64"
          "2a0e:8f01:1000:46::107/64"
        ];
        IPv6AcceptRA = "no";
      };
    };

    # PIXINKO
    networks."10-ens22" = {
      matchConfig.Name = "ens22";
      networkConfig = {
        Address = [
          "10.192.72.1/24"
          "2a0c:b641:870::1/64"
        ];
        IPv6AcceptRA = "no";
      };
    };
  };

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  clement.profile.router.bird.config = ./bird.conf;
  # TODO: restrict source IP
  networking.firewall.extraCommands = ''
    ip6tables -A nixos-fw -p tcp --dport 179 -j ACCEPT
  '';

  system.stateVersion = "23.11";
}
