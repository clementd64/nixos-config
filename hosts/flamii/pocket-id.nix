{ config, pkgs, ... }:
{
  clement.local.addresses = [ "2a0c:b641:2b2::11/128" ];
  clement.firewall.dst."tcp:443" = ["2a0c:b641:2b2::11"];
  clement.firewall.dst."tcp:80" = ["2a0c:b641:2b2::11"];

  clement.credentials.pocket-id = {
    file = ./secrets.json;
    service = "pocket-id";
    secrets = {
      "encryption-key".extract = ''["pocket-id"]["encryption-key"]'';
    };
  };

  clement.acme.certificates."id.dubreuil.dev" = {
    reload = "pocket-id.service";
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
      LoadCredential = [
        "tls-cert.pem:${config.clement.acme.certificates."id.dubreuil.dev".cert}"
        "tls-key.pem:${config.clement.acme.certificates."id.dubreuil.dev".key}"
      ];
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
    environment = {
      DB_CONNECTION_STRING = "postgresql://pocketid@/pocketid?sslmode=disable";
      ENCRYPTION_KEY_FILE = "%d/encryption-key";
      HOST = "2a0c:b641:2b2::11";
      PORT = "443";
      TLS_CERT = "%d/tls-cert.pem";
      TLS_KEY = "%d/tls-key.pem";
      APP_URL = "https://id.dubreuil.dev";
      FILE_BACKEND = "database";
      UI_CONFIG_DISABLED = "true";
      GEOLITE_DB_URL = "https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download/GeoLite2-City.mmdb";
      GEOLITE_DB_PATH = "%C/pocket-id/GeoLite2-City.mmdb";
    };
  };
}
