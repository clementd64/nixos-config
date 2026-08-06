{ config, pkgs, lib, ... }:
{
  clement.local.addresses = [ "2a0c:b641:2b2::10/128" ];
  clement.firewall.dst."tcp:443" = ["2a0c:b641:2b2::10"];
  clement.firewall.dst."tcp:80" = ["2a0c:b641:2b2::10"];

  clement.credentials.miniflux = {
    file = ./secrets.json;
    service = "miniflux";
    secrets = {
      "oauth2-client-id".extract = ''["miniflux"]["oauth2_client_id"]'';
      "oauth2-client-secret".extract = ''["miniflux"]["oauth2_client_secret"]'';
    };
  };

  clement.acme.certificates."miniflux.dubreuil.dev" = {
    reload = "miniflux.service";
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
      LoadCredential = [
        "tls-cert.pem:${config.clement.acme.certificates."miniflux.dubreuil.dev".cert}"
        "tls-key.pem:${config.clement.acme.certificates."miniflux.dubreuil.dev".key}"
      ];
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
    environment = {
      DATABASE_URL = "host=/run/postgresql user=miniflux dbname=miniflux sslmode=disable";
      LISTEN_ADDR = "[2a0c:b641:2b2::10]:443";
      CERT_FILE = "%d/tls-cert.pem";
      KEY_FILE = "%d/tls-key.pem";
      BASE_URL = "https://miniflux.dubreuil.dev/";
      HTTPS = "1";
      RUN_MIGRATIONS = "1";

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