{ config, pkgs, lib, ... }:
let
  settings = {
    DB_CONNECTION_STRING = "postgresql://pocketid@db.as212625.net/pocketid?sslmode=verify-full&sslcert=${config.clement.secrets."pocket-id-postgresql-tls-cert".path}&sslkey=${config.clement.secrets."pocket-id-postgresql-tls-key".path}&sslrootcert=${config.clement.secrets."pocket-id-postgresql-tls-ca".path}";
    ENCRYPTION_KEY_FILE = config.clement.secrets."pocket-id-encryption-key".path;
    HOST = "2a0c:b641:2b2::11";
    PORT = 443;
    TLS_CERT = config.clement.acme.certificates."id.dubreuil.dev".cert;
    TLS_KEY = config.clement.acme.certificates."id.dubreuil.dev".key;
    APP_URL = "https://id.dubreuil.dev";
    FILE_BACKEND = "database";
    UI_CONFIG_DISABLED = true;
    GEOLITE_DB_URL = "https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download/GeoLite2-City.mmdb";
    GEOLITE_DB_PATH = "%C/pocket-id/GeoLite2-City.mmdb";
  };
in {
  clement.local.addresses = [ "2a0c:b641:2b2::11/128" ];
  clement.firewall.dst."tcp:443" = ["2a0c:b641:2b2::11"];
  clement.firewall.dst."tcp:80" = ["2a0c:b641:2b2::11"];

  clement.secrets = {
    pocket-id-postgresql-tls-ca = {
      file = ./secrets.json;
      extract = ''["pocket-id"]["postgresql"]["ca"]'';
      group = "pocket-id";
      before = [ "pocket-id.service" ];
    };
    pocket-id-postgresql-tls-cert = {
      file = ./secrets.json;
      extract = ''["pocket-id"]["postgresql"]["cert"]'';
      group = "pocket-id";
      before = [ "pocket-id.service" ];
    };
    pocket-id-postgresql-tls-key = {
      file = ./secrets.json;
      extract = ''["pocket-id"]["postgresql"]["key"]'';
      group = "pocket-id";
      before = [ "pocket-id.service" ];
    };
    pocket-id-encryption-key = {
      file = ./secrets.json;
      extract = ''["pocket-id"]["encryption-key"]'';
      group = "pocket-id";
      before = [ "pocket-id.service" ];
    };
  };

  clement.acme.certificates."id.dubreuil.dev" = {
    reload = "pocket-id.service";
    group = "pocket-id";
  };

  systemd.services.pocket-id = {
    description = "Pocket ID service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    protect = {
      enable = true;
      memoryExec = true;
    };
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.pocket-id}/bin/pocket-id";
      User = "pocket-id";
      Group = "pocket-id";
      Restart = "always";
      RestartSec = 5;
      CacheDirectory = "pocket-id";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
    environment = lib.mapAttrs (_: toString) settings;
  };

  users.users.pocket-id = {
    home = "/var/empty";
    isSystemUser = true;
    group = "pocket-id";
  };
  users.groups.pocket-id = {};
}