{ config, pkgs, ... }:
{
  clement.credentials.pocket-id = {
    file = ../secrets.json;
    service = "pocket-id";
    secrets = {
      "encryption-key".extract = ''["pocket-id"]["encryption-key"]'';
    };
  };

  systemd.services.pocket-id = {
    description = "Pocket ID service";
    after = [ "network.target" "postgresql.service" ];
    wants = [ "postgresql.service" ];
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
      DB_CONNECTION_STRING = "postgresql://pocketid@/pocketid?sslmode=disable";
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

  clement.restic.postgresql.databases.pocketid = {};
}
