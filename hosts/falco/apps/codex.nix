{ config, pkgs, ... }:
{
  clement.credentials.codex = {
    file = ../secrets.json;
    service = "codex";
    secrets = {
      "tmdb-apikey".extract = ''["codex"]["tmdb_apikey"]'';
    };
  };

  systemd.services.codex = {
    description = "codex service";
    after = [ "network.target" "postgresql.service" ];
    wants = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    protect = {
      enable = true;
      memoryExec = true;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = let
        pkg = pkgs.codex.override {
          frontendEnv = {
            VITE_OIDC_CLIENT_ID = "codex";
            VITE_OIDC_DISCOVERY_ENDPOINT = "https://id.dubreuil.dev";
            VITE_OIDC_PROVIDER_NAME = "PocketID";
          };
        };
      in "${pkg}/bin/codex";
      Restart = "always";
      RestartSec = 5;
    };
    environment = {
      DATABASE_URL = "host=/run/postgresql user=codex dbname=codex sslmode=disable";
      LISTEN_ADDR = "[::1]:8082";
      OIDC_CLIENT_ID = "codex";
      OIDC_DISCOVERY_ENDPOINT = "https://id.dubreuil.dev";
      TMDB_APIKEY_FILE = "%d/tmdb-apikey";
    };
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

  clement.restic.postgresql.databases.codex = {};
}
