{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-ens2" = {
      matchConfig.Name = "ens2";
      networkConfig = {
        DHCP = "ipv6";
      };
      ipv6AcceptRAConfig = {
        UseDNS = "no";
      };
    };
  };

  swapDevices = [ {
    device = "/nix/swap";
    size = 2*1024;
  } ];

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

  system.stateVersion = "25.11";
}
