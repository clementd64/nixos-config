{ config, pkgs, ... }:
{
  clement.credentials.miniflux = {
    file = ./secrets.json;
    service = "miniflux";
    secrets = {
      "oauth2-client-id".extract = ''["miniflux"]["oauth2_client_id"]'';
      "oauth2-client-secret".extract = ''["miniflux"]["oauth2_client_secret"]'';
    };
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

  clement.traefik = {
    dynamic = {
      http = {
        routers.miniflux = {
          rule = "Host(`miniflux.dubreuil.dev`) && !Path(`/metrics`)";
          service = "miniflux";
        };
        services.miniflux.loadBalancer.servers = [{
          url = "http://[::1]:8081";
        }];
      };
    };
  };
}
