{ config, pkgs, lib, ... }:
{
  clement.local.addresses = [ "2a0c:b641:2b0:100::2/128" ];
  clement.firewall.dst."tcp:443" = ["2a0c:b641:2b0:100::2"];
  clement.firewall.dst."tcp:80" = ["2a0c:b641:2b0:100::2"];

  clement.credentials.grafana = {
    file = ./secrets.json;
    service = "grafana";
    secrets = {
      "secret-key".extract = ''["grafana"]["secret_key"]'';
      "oauth2-client-id".extract = ''["grafana"]["oauth2_client_id"]'';
      "oauth2-client-secret".extract = ''["grafana"]["oauth2_client_secret"]'';
    };
  };

  clement.acme.certificates."grafana.dubreuil.dev" = {
    reload = "grafana.service";
  };

  systemd.services.grafana = {
    description = "Grafana service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    protect = {
      enable = true;
      memoryExec = true;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.grafana}/bin/grafana server --homepath ${pkgs.grafana}/share/grafana";
      Restart = "on-failure";
      RestartSec = 5;
      RuntimeDirectory = "grafana";
      LoadCredential = [
        "tls-cert.pem:${config.clement.acme.certificates."grafana.dubreuil.dev".cert}"
        "tls-key.pem:${config.clement.acme.certificates."grafana.dubreuil.dev".key}"
      ];
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
    environment = {
      GF_SERVER_PROTOCOL = "https";
      GF_SERVER_MIN_TLS_VERSION = "TLS1.3";
      GF_SERVER_HTTP_ADDR = "2a0c:b641:2b0:100::2";
      GF_SERVER_HTTP_PORT = "443";
      GF_SERVER_DOMAIN = "grafana.dubreuil.dev";
      GF_SERVER_ENFORCE_DOMAIN = "true";
      GF_SERVER_CERT_FILE = "%d/tls-cert.pem";
      GF_SERVER_CERT_KEY = "%d/tls-key.pem";
      GF_SERVER_STATIC_ROOT_PATH = "${pkgs.grafana}/share/grafana/public";
      GF_SERVER_ENABLE_GZIP = "true";
      GF_DATABASE_TYPE = "postgres";
      GF_DATABASE_HOST = "/var/run/postgresql";
      GF_DATABASE_NAME = "grafana";
      GF_DATABASE_USER = "grafana";
      GF_DATABASE_SSL_MODE = "disable";
      GF_SECURITY_SECRET_KEY = "$__file{%d/secret-key}";
      GF_SECURITY_DISABLE_INITIAL_ADMIN_CREATION = "true";
      GF_AUTH_DISABLE_LOGIN_FORM = "true";
      GF_AUTH_GENERIC_OAUTH_ENABLED = "true";
      GF_AUTH_GENERIC_OAUTH_NAME = "PocketID";
      GF_AUTH_GENERIC_OAUTH_CLIENT_ID = "$__file{%d/oauth2-client-id}";
      GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET = "$__file{%d/oauth2-client-secret}";
      GF_AUTH_GENERIC_OAUTH_AUTH_URL = "https://id.dubreuil.dev/authorize";
      GF_AUTH_GENERIC_OAUTH_TOKEN_URL = "https://id.dubreuil.dev/api/oidc/token";
      GF_AUTH_GENERIC_OAUTH_API_URL = "https://id.dubreuil.dev/api/oidc/userinfo";
      GF_AUTH_GENERIC_OAUTH_SCOPES = "openid profile email";
      GF_AUTH_GENERIC_OAUTH_USE_PKCE = "true";
      GF_AUTH_GENERIC_OAUTH_USE_REFRESH_TOKEN = "true";
      GF_AUTH_GENERIC_OAUTH_VALIDATE_ID_TOKEN = "true";
      GF_AUTH_GENERIC_OAUTH_JWK_SET_URL = "https://id.dubreuil.dev/.well-known/jwks.json";
      GF_AUTH_GENERIC_OAUTH_EMAIL_ATTRIBUTE_NAME = "email:primary";
      GF_AUTH_GENERIC_OAUTH_SKIP_ORG_ROLE_SYNC = "true";
      # Disable writable directory
      GF_LOG_MODE = "console";
      GF_PATHS_DATA = "%t/grafana";
      GF_PLUGINS_PLUGIN_ADMIN_ENABLED = "false";
      GF_PLUGINS_PREINSTALL_DISABLED = "true";
      GF_PLUGINS_PREINSTALL_AUTO_UPDATE = "false";
    };
  };
}