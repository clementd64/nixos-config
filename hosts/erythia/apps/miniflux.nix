{ config, pkgs, ... }:
{
  clement.local.addresses = [ "2a0c:b641:2b0:100::3/128" ];
  clement.firewall.dst."tcp:443" = ["2a0c:b641:2b0:100::3"];
  clement.firewall.dst."tcp:80" = ["2a0c:b641:2b0:100::3"];

  clement.credentials.miniflux = {
    file = ../secrets.json;
    service = "miniflux";
    secrets = {
      "oauth2-client-id".extract = ''["miniflux"]["oauth2_client_id"]'';
      "oauth2-client-secret".extract = ''["miniflux"]["oauth2_client_secret"]'';
    };
  };

  clement.acme.certificates."miniflux.dubreuil.dev" = {
    service = "miniflux";
  };

  services.opentelemetry-collector.settings = {
    receivers."prometheus/miniflux".config.scrape_configs = [
      {
        job_name = "miniflux";
        scrape_interval = "60s";
        scheme = "https";
        metrics_path = "/metrics";
        tls_config.server_name = "miniflux.dubreuil.dev";
        static_configs = [
          { targets = [ "[2a0c:b641:2b0:100::3]:443" ]; }
        ];
      }
    ];
    service.pipelines.metrics.receivers = [ "prometheus/miniflux" ];
  };

  systemd.services.miniflux = {
    description = "Miniflux service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    protect = {
      enable = true;
      memoryExec = true;
    };
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.miniflux}/bin/miniflux";
      WatchdogSec = 60;
      WatchdogSignal = "SIGKILL";
      Restart = "always";
      RestartSec = 5;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
    environment = {
      DATABASE_URL = "host=/run/postgresql user=miniflux dbname=miniflux sslmode=disable";
      LISTEN_ADDR = "[2a0c:b641:2b0:100::3]:443";
      CERT_FILE = config.clement.acme.certificates."miniflux.dubreuil.dev".credentials.cert;
      KEY_FILE = config.clement.acme.certificates."miniflux.dubreuil.dev".credentials.key;
      BASE_URL = "https://miniflux.dubreuil.dev/";
      HTTPS = "1";
      RUN_MIGRATIONS = "1";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "2a0c:b641:2b0:100::3/128";

      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID_FILE = "%d/oauth2-client-id";
      OAUTH2_CLIENT_SECRET_FILE = "%d/oauth2-client-secret";
      OAUTH2_REDIRECT_URL = "https://miniflux.dubreuil.dev/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://id.dubreuil.dev";
      OAUTH2_OIDC_PROVIDER_NAME = "PocketID";
      OAUTH2_USER_CREATION = "1";
      DISABLE_LOCAL_AUTH = "1";
    };
  };
}
