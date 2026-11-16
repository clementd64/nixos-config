{ config, pkgs, lib, ... }:
{
  clement.credentials.codex = {
    file = ../secrets.json;
    service = "codex";
    secrets = {
      "postgresql-tls-ca.pem".extract = ''["codex"]["postgresql"]["ca"]'';
      "postgresql-tls-cert.pem".extract = ''["codex"]["postgresql"]["cert"]'';
      "postgresql-tls-key.pem".extract = ''["codex"]["postgresql"]["key"]'';
      "tmdb-apikey".extract = ''["codex"]["tmdb_apikey"]'';
      "igdb-client-id".extract = ''["codex"]["igdb_client_id"]'';
      "igdb-client-secret".extract = ''["codex"]["igdb_client_secret"]'';
    };
  };

  systemd.services = let
    pkg = pkgs.codex.override {
      frontendEnv = {
        VITE_OIDC_CLIENT_ID = "codex";
        VITE_OIDC_DISCOVERY_ENDPOINT = "https://id.dubreuil.dev";
        VITE_OIDC_PROVIDER_NAME = "PocketID";
      };
    };
  in {
    codex = {
      description = "codex service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      protect = {
        enable = true;
        memoryExec = true;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkg}/bin/codex server";
        Restart = "always";
        RestartSec = 5;
      };
      environment = {
        DATABASE_URL = "host=db.as212625.net user=codex dbname=codex sslmode=verify-full sslcert=%d/postgresql-tls-cert.pem sslkey=%d/postgresql-tls-key.pem sslrootcert=%d/postgresql-tls-ca.pem";
        LISTEN_ADDR = "[::1]:8082";
        OIDC_CLIENT_ID = "codex";
        OIDC_DISCOVERY_ENDPOINT = "https://id.dubreuil.dev";
        TMDB_APIKEY_FILE = "%d/tmdb-apikey";
        IGDB_CLIENT_ID_FILE = "%d/igdb-client-id";
        IGDB_CLIENT_SECRET_FILE = "%d/igdb-client-secret";
      };
    };

    codex-cron = {
      description = "codex cron";
      protect = {
        enable = true;
        memoryExec = true;
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkg}/bin/codex cron";
        LoadCredential = lib.mapAttrsToList (name: secret: "${name}:${secret.path}") config.clement.credentials.codex.secrets;
      };
      environment = {
        DATABASE_URL = "host=db.as212625.net user=codex dbname=codex sslmode=verify-full sslcert=%d/postgresql-tls-cert.pem sslkey=%d/postgresql-tls-key.pem sslrootcert=%d/postgresql-tls-ca.pem";
        TMDB_APIKEY_FILE = "%d/tmdb-apikey";
        IGDB_CLIENT_ID_FILE = "%d/igdb-client-id";
        IGDB_CLIENT_SECRET_FILE = "%d/igdb-client-secret";
      };
    };
  };

  systemd.timers.codex-cron = {
    description = "Codex cron";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "hourly";
  };

  clement.traefik = {
    dynamic = {
      http = {
        routers.codex = {
          rule = "Host(`codex.dubreuil.dev`)";
          service = "codex";
        };
        services.codex.loadBalancer.servers = [{
          url = "http://[::1]:8082";
        }];
      };
    };
  };
}
