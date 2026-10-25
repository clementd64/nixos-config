{ config, pkgs, ... }:
{
  clement.credentials.pocket-id = {
    file = ../secrets.json;
    service = "pocket-id";
    secrets = {
      "postgresql-tls-ca.pem".extract = ''["pocket-id"]["postgresql"]["ca"]'';
      "postgresql-tls-cert.pem".extract = ''["pocket-id"]["postgresql"]["cert"]'';
      "postgresql-tls-key.pem".extract = ''["pocket-id"]["postgresql"]["key"]'';
      "encryption-key".extract = ''["pocket-id"]["encryption-key"]'';
    };
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
      DynamicUser = true;
      User = "pocketid";
      Restart = "always";
      RestartSec = 5;
      CacheDirectory = "pocket-id";
    };
    environment = {
      DB_CONNECTION_STRING = "postgresql://pocketid@db.as212625.net/pocketid?sslmode=verify-full&sslcert=%d/postgresql-tls-cert.pem&sslkey=%d/postgresql-tls-key.pem&sslrootcert=%d/postgresql-tls-ca.pem";
      ENCRYPTION_KEY_FILE = "%d/encryption-key";
      HOST = "::1";
      PORT = "1411";
      TRUST_PROXY = "::1";
      APP_URL = "https://id.dubreuil.dev";
      FILE_BACKEND = "database";
      UI_CONFIG_DISABLED = "true";
      GEOLITE_DB_URL = "https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download/GeoLite2-City.mmdb";
      GEOLITE_DB_PATH = "%C/pocket-id/GeoLite2-City.mmdb";
    };
  };

  clement.traefik = {
    dynamic = {
      http = {
        routers.pocket-id = {
          rule = "Host(`id.dubreuil.dev`)";
          service = "pocket-id";
        };
        services.pocket-id.loadBalancer.servers = [{
          url = "http://[::1]:1411";
        }];
      };
    };
  };
}
