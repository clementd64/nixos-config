{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [
    "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA61620654480FGN"
    "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA634507N9480FGN"
  ];

  systemd.network = {
    networks."10-eno1" = {
      matchConfig.Name = "eno1";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2001:41d0:2:9ed3::1/56";
        Gateway = "2001:41d0:2:9eff:ff:ff:ff:ff";
      };
    };
  };

  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = true;
    package = pkgs.postgresql_17;
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser    address                                  auth-method
      local  all       postgres                                           peer
    '';
  };

  clement.docker = {
    enable = true;
    cli.config = {
      secretsFile = ./secrets.json;
      extract = ''["docker"]'';
    };
  };

  clement.compose = {
    enable = true;
    config = "oci://ghcr.io/clementd64/nixos-config/cadensia:latest";
  };

  clement.traefik = {
    enable = true;
    config = {
      entryPoints.https = {
        address = ":443";
        http.tls = {};
      };
    };
    dynamic = {
      tls.certificates = [{
        certFile = config.clement.secrets."tls-cert".path;
        keyFile = config.clement.secrets."tls-key".path;
      }];
    };
  };

  clement.secrets = {
    "tls-cert" = {
      file = ./secrets.json;
      extract = ''["tls"]["cert"]'';
      user = "traefik";
    };
    "tls-key" = {
      file = ./secrets.json;
      extract = ''["tls"]["key"]'';
      user = "traefik";
    };
  };

  clement.wireguard.fly = {
    secretsFile = ./secrets.json;
    privateKey = ''["fly"]["private-key"]'';
    publicKey = "trM7zOMMKsWHT+F6V08e4e5YVe3VVgf6M8zONd7qzwQ=";
    addresses = ["fdaa:1:70d9:a7b:1596:0:a:202/120"];
    allowedIps = ["fdaa:1:70d9::/48"];
    endpoint = "cdg1.gateway.6pn.dev:51820";
    dns = ["fdaa:1:70d9::3"];
    domains = ["~internal."];
  };

  system.stateVersion = "25.05";
}
