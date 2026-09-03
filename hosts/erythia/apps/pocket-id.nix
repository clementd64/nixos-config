{ config, pkgs, ... }:
{
  clement.local.addresses = [ "2a0c:b641:2b0:100::4/128" ];
  clement.firewall.dst."tcp:443" = ["2a0c:b641:2b0:100::4"];
  clement.firewall.dst."tcp:80" = ["2a0c:b641:2b0:100::4"];

  clement.credentials.pocket-id = {
    file = ../secrets.json;
    service = "pocket-id";
    secrets = {
      "encryption-key".extract = ''["pocket-id"]["encryption-key"]'';
    };
  };

  clement.acme.certificates."id.dubreuil.dev" = {
    service = "pocket-id";
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
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
    environment = {
      DB_CONNECTION_STRING = "postgresql://pocketid@/pocketid?sslmode=disable";
      ENCRYPTION_KEY_FILE = "%d/encryption-key";
      HOST = "2a0c:b641:2b0:100::4";
      PORT = "443";
      TLS_CERT_FILE = config.clement.acme.certificates."id.dubreuil.dev".credentials.cert;
      TLS_KEY_FILE = config.clement.acme.certificates."id.dubreuil.dev".credentials.key;
      APP_URL = "https://id.dubreuil.dev";
      FILE_BACKEND = "database";
      UI_CONFIG_DISABLED = "true";
      GEOLITE_DB_URL = "https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download/GeoLite2-City.mmdb";
      GEOLITE_DB_PATH = "%C/pocket-id/GeoLite2-City.mmdb";
      OTEL_TRACES_EXPORTER = "otlp";
      OTEL_METRICS_EXPORTER = "otlp";
      OTEL_LOGS_EXPORTER = "otlp";
      OTEL_EXPORTER_OTLP_ENDPOINT = "http://localhost:4317";
      OTEL_EXPORTER_OTLP_PROTOCOL = "grpc";
    };
  };
}
