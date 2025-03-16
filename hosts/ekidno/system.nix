{ lib, pkgs, ... }:
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
          "194.28.99.42/27"
          "2a0c:b640:13:42::1/48"
        ];
        Gateway = [
          "194.28.99.62"
          "2a0c:b640:13::ffff"
        ];
        IPv6AcceptRA = false;
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
        IPv6AcceptRA = false;
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
        IPv6AcceptRA = false;
      };
    };

    # bgp.exchange
    networks."10-ens21" = {
      matchConfig.Name = "ens21";
      networkConfig = {
        Address = [
          "100.66.181.7/22"
          "2a0e:8f01:1000:46::107/64"
        ];
        IPv6AcceptRA = false;
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
        IPv6AcceptRA = false;
      };
    };

    # Loopback
    netdevs."20-dum0".netdevConfig = {
      Name = "dum0";
      Kind = "dummy";
    };

    networks."20-dum0" = {
      matchConfig.Name = "dum0";
      networkConfig = {
        Address = [
          "2a0c:b641:2b1::1/128"
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
    "2a0c:b640:13::ffff" # Servperso
    "2a0c:b641:870::ffff" # PIXINKO
    "2001:7f8:f2:e1::6939:1" # Hurricane Electric
    "2001:7f8:f2:e1:0:4:1051:1" # FreeTransit
    "2a0c:b641:701::a5:20:2409:1" # LocIX DUS RS1
    "2a0c:b641:701::a5:20:2409:2" # LocIX DUS RS2
    "2001:7f8:f2:e1::babe:1" # LocIX FRA RS1
    "2001:7f8:f2:e1::dead:1" # LocIX FRA RS2
    "2001:7f8:f2:e1::be5a" # LocIX FRA RS3
    "2a0e:8f01:1000:46::1" # bgp.exchange
    "2a0c:2f07:9459::b4" # bgp.tools
    "2a0c:b641:701:0:a5:0:112:1" # AS112 LocIX DUS
    "2001:7f8:f2:e1::112" # AS112 LocIX FRA
  ];

  clement.http2https.enable = true;

  clement.mesh = {
    secretsFile = ./secrets.json;
    address = "fd34:ad42:6ef8::4";
    port = 57205;
  };

  system.stateVersion = "23.11";
}
