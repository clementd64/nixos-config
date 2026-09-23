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
    service = "traefik";
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
    };
    environment = {
      DATABASE_URL = "host=/run/postgresql user=miniflux dbname=miniflux sslmode=disable";
      LISTEN_ADDR = "[::1]:8081";
      BASE_URL = "https://miniflux.dubreuil.dev/";
      HTTPS = "1";
      TRUSTED_REVERSE_PROXY_NETWORKS = "::1/128";
      RUN_MIGRATIONS = "1";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "::1/128";

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

  services.opentelemetry-collector.settings = {
    receivers."prometheus/miniflux".config.scrape_configs = [
      {
        job_name = "miniflux";
        scrape_interval = "60s";
        scheme = "http";
        metrics_path = "/metrics";
        static_configs = [
          { targets = [ "[::1]:8081" ]; }
        ];
      }
    ];
    service.pipelines.metrics.receivers = [ "prometheus/miniflux" ];
  };

  clement.traefik = {
    config.entryPoints.miniflux.address = "[2a0c:b641:2b0:100::3]:443";
    dynamic = {
      tls.certificates = [{
        certFile = builtins.baseNameOf config.clement.acme.certificates."miniflux.dubreuil.dev".credentials.cert;
        keyFile = builtins.baseNameOf config.clement.acme.certificates."miniflux.dubreuil.dev".credentials.key;
      }];
      http = {
        routers.miniflux = {
          entryPoints = [ "miniflux" "ipv4" ];
          rule = "Host(`miniflux.dubreuil.dev`) && !Path(`/metrics`)";
          service = "miniflux";
          tls = {};
        };
        services.miniflux.loadBalancer.servers = [{
          url = "http://[::1]:8081";
        }];
      };
    };
  };
}
