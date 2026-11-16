{ config, pkgs, ... }:
{
  clement.credentials.miniflux = {
    file = ../secrets.json;
    service = "miniflux";
    secrets = {
      "postgresql-tls-ca.pem".extract = ''["miniflux"]["postgresql"]["ca"]'';
      "postgresql-tls-cert.pem".extract = ''["miniflux"]["postgresql"]["cert"]'';
      "postgresql-tls-key.pem".extract = ''["miniflux"]["postgresql"]["key"]'';
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
      DATABASE_URL = "host=db.as212625.net user=miniflux dbname=miniflux sslmode=verify-full sslcert=%d/postgresql-tls-cert.pem sslkey=%d/postgresql-tls-key.pem sslrootcert=%d/postgresql-tls-ca.pem";
      LISTEN_ADDR = "[${pkgs.net.ip.falco}]:8081";
      BASE_URL = "https://miniflux.dubreuil.dev/";
      HTTPS = "1";
      TRUSTED_REVERSE_PROXY_NETWORKS = "${pkgs.net.ip.zoness}/128";
      RUN_MIGRATIONS = "1";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "${pkgs.net.ip.zoness}/128";

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

  clement.firewall.src."tcp:8081" = ["${pkgs.net.ip.zoness}/128"];
}
