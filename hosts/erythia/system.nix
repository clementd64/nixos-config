{ config, lib, pkgs, ... }:
{
  clement.profile.router.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0";

  systemd.network = {
    netdevs."10-as212625" = {
      netdevConfig = {
        Name = "as212625";
        Kind = "vrf";
      };
      vrfConfig.Table = 212625;
    };
    networks."10-as212625".matchConfig.Name = "as212625";

    networks."10-ens3" = {
      matchConfig = {
        Name = "ens3";
        PermanentMACAddress = "fa:16:3e:96:0c:bf";
      };
      networkConfig = {
        DHCP = "ipv4";
        Address = ["2001:41d0:305:2100::dd40/128"];
        Gateway = ["2001:41d0:305:2100::1"];
        IPv6AcceptRA = false;
      };
      routes = [{
        Destination = "2001:41d0:305:2100::/64";
        Scope = "link";
      }];
    };
  };

  clement.profile.mesh.enable = true;
  clement.mesh.vrf = "as212625";

  clement.wireguard = {
    ekidno = {
      port = 51822;
      endpoint = "ekidno.h.as212625.net:51822";
      presharedKey = ''["wireguard"]["ekidno"]["preshared-key"]'';
      privateKey = ''["wireguard"]["ekidno"]["private-key"]'';
      publicKey = "DMwv37qI9m1VqXKVZVI2c/GUW7B/0Y52qWOU+ZRVsGw=";
      secretsFile = ./secrets.json;
      vrf = "as212625";
    };
    flamii = {
      port = 51823;
      endpoint = "flamii.h.as212625.net:51823";
      presharedKey = ''["wireguard"]["flamii"]["preshared-key"]'';
      privateKey = ''["wireguard"]["flamii"]["private-key"]'';
      publicKey = "Q41VPpfj9todiCdur5fmOfERBlXhcO+75j4lML03hzc=";
      secretsFile = ./secrets.json;
      vrf = "as212625";
    };
  };

  clement.profile.router.bird.config = [ ./bird.conf ];
  clement.profile.router.bird.defines = {
    EKIDNO_IP = pkgs.net.genLinkLocal "ekidno";
    FLAMII_IP = pkgs.net.genLinkLocal "flamii";
  };
  clement.profile.router.bgp.allowedIp = [
    (pkgs.net.genLinkLocal "ekidno")
    (pkgs.net.genLinkLocal "flamii")
  ];

  clement.secrets = {
    postgresql-tls-ca = {
      file = ./secrets.json;
      extract = ''["postgresql"]["ca"]'';
      group = "postgres";
      before = [ "postgresql.service" ];
    };
    postgresql-tls-cert = {
      file = ./secrets.json;
      extract = ''["postgresql"]["cert"]'';
      group = "postgres";
      before = [ "postgresql.service" ];
    };
    postgresql-tls-key = {
      file = ./secrets.json;
      extract = ''["postgresql"]["key"]'';
      group = "postgres";
      before = [ "postgresql.service" ];
    };
  };

  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = true;
    package = pkgs.postgresql_18;
    authentication = lib.mkOverride 10 ''
      #type   database  DBuser    address             auth-method
      local   all       postgres                      peer
      hostssl miniflux  miniflux  2a0c:b641:2b0::/44  cert
      hostssl pocketid  pocketid  2a0c:b641:2b0::/44  cert
    '';
    settings = {
      ssl = true;
      ssl_ca_file = config.clement.secrets."postgresql-tls-ca".path;
      ssl_cert_file = config.clement.secrets."postgresql-tls-cert".path;
      ssl_key_file = config.clement.secrets."postgresql-tls-key".path;
      ssl_min_protocol_version = "TLSv1.3";
    };
  };

  clement.firewall.src."tcp:5432" = ["2a0c:b641:2b0::/44"];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/postgresql"
    ];
  };

  system.stateVersion = "26.05";
}
