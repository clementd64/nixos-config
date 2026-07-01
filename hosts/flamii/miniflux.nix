{ config, pkgs, lib, ... }:
let
  settings = {
    DATABASE_URL = "host=db.as212625.net user=miniflux dbname=miniflux sslmode=verify-full sslcert=${config.clement.secrets."miniflux-postgresql-tls-cert".path} sslkey=${config.clement.secrets."miniflux-postgresql-tls-key".path} sslrootcert=${config.clement.secrets."miniflux-postgresql-tls-ca".path}";
    LISTEN_ADDR = "[2a0c:b641:2b2::10]:443";
    CERT_FILE = config.clement.secrets."miniflux-tls-cert".path;
    KEY_FILE = config.clement.secrets."miniflux-tls-key".path;
    BASE_URL = "https://miniflux.dubreuil.dev/";
    HTTPS = 1;
    RUN_MIGRATIONS = 1;

    OAUTH2_PROVIDER = "oidc";
    OAUTH2_CLIENT_ID_FILE = config.clement.secrets."miniflux-oauth2_client_id".path;
    OAUTH2_CLIENT_SECRET_FILE = config.clement.secrets."miniflux-oauth2_client_secret".path;
    OAUTH2_REDIRECT_URL = "https://miniflux.dubreuil.dev/oauth2/oidc/callback";
    OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://id.dubreuil.dev";
    OAUTH2_OIDC_PROVIDER_NAME = "PocketID";
    OAUTH2_USER_CREATION = 1;
    DISABLE_LOCAL_AUTH = 1;
  };
in {
  clement.dummy.miniflux.addresses = [ "2a0c:b641:2b2::10/128" ];
  clement.firewall.dst."tcp:443" = ["2a0c:b641:2b2::10"];

  clement.secrets = {
    miniflux-postgresql-tls-ca = {
      file = ./secrets.json;
      extract = ''["miniflux"]["postgresql"]["ca"]'';
      group = "miniflux";
      before = [ "miniflux.service" ];
    };
    miniflux-postgresql-tls-cert = {
      file = ./secrets.json;
      extract = ''["miniflux"]["postgresql"]["cert"]'';
      group = "miniflux";
      before = [ "miniflux.service" ];
    };
    miniflux-postgresql-tls-key = {
      file = ./secrets.json;
      extract = ''["miniflux"]["postgresql"]["key"]'';
      group = "miniflux";
      before = [ "miniflux.service" ];
    };
    miniflux-tls-cert = {
      file = ./secrets.json;
      extract = ''["miniflux"]["cert"]'';
      group = "miniflux";
      before = [ "miniflux.service" ];
    };
    miniflux-tls-key = {
      file = ./secrets.json;
      extract = ''["miniflux"]["key"]'';
      group = "miniflux";
      before = [ "miniflux.service" ];
    };
    miniflux-oauth2_client_id = {
      file = ./secrets.json;
      extract = ''["miniflux"]["oauth2_client_id"]'';
      group = "miniflux";
      before = [ "miniflux.service" ];
    };
    miniflux-oauth2_client_secret = {
      file = ./secrets.json;
      extract = ''["miniflux"]["oauth2_client_secret"]'';
      group = "miniflux";
      before = [ "miniflux.service" ];
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
      User = "miniflux";
      Group = "miniflux";
      WatchdogSec = 60;
      WatchdogSignal = "SIGKILL";
      Restart = "always";
      RestartSec = 5;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
    environment = lib.mapAttrs (_: toString) settings;
  };

  users.users.miniflux = {
    home = "/var/empty";
    isSystemUser = true;
    group = "miniflux";
  };
  users.groups.miniflux = {};
}