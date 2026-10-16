{ lib, pkgs, ... }:
let
  synapse = pkgs.matrix-synapse.override {
    extras = [ "postgres" "url-preview" "systemd" "oidc" ];
    plugins = [ pkgs.matrix-synapse.plugins.matrix-synapse-s3-storage-provider pkgs.synapse-delegation pkgs.synapse-miniflux ];
  };

  settings = (pkgs.formats.yaml {}).generate "synapse-homeserver.yaml" {
    server_name = "dubreuil.dev";
    public_baseurl = "https://matrix.dubreuil.dev/";
    report_stats = false;
    enable_registration = false;
    password_config.enabled = false;
    oidc_providers = [{
      idp_id = "pocket-id";
      idp_name = "Pocket ID";
      issuer = "https://id.dubreuil.dev";
      client_id = "synapse";
      client_auth_method = "none";
      pkce_method = "always";
      scopes = [ "openid" "profile" "email" ];
      enable_registration = true;
      user_mapping_provider.config = {
        localpart_template = "{{ user.preferred_username }}";
        display_name_template = "{{ user.name }}";
        email_template = "{{ user.email }}";
      };
    }];
    listeners = [{
      port = 8008;
      bind_addresses = [ "::1" ];
      type = "http";
      tls = false;
      x_forwarded = true;
      additional_resources."/_synapse/server-delegation" = {
        module = "synapse_delegation.FederationDelegation";
        config.server = "matrix.dubreuil.dev:443";
      };
      additional_resources."/_synapse/client/miniflux/webhook" = {
        module = "synapse_miniflux.MinifluxWebhook";
        config.config_file = "/run/credentials/synapse.service/miniflux";
      };
      resources = [{ names = [ "client" "federation" ]; compress = false; }];
    }];
    database = {
      name = "psycopg2";
      args = {
        host = "/run/postgresql";
        user = "synapse";
        dbname = "synapse";
        cp_min = 5;
        cp_max = 10;
      };
    };
    signing_key_path = "/run/credentials/synapse.service/signing-key";
    enable_local_media_storage = true; # See element-hq/synapse#19413
    media_store_path = "/var/cache/synapse/media";
    url_preview_enabled = true;
    ip_range_blacklist = pkgs.net.bogonIPv4 ++ pkgs.net.bogonIPv6;
    url_preview_ip_range_blacklist = pkgs.net.bogonIPv4 ++ pkgs.net.bogonIPv6;
  };
in
{
  clement.credentials.synapse = {
    file = ./secrets.json;
    service = "synapse";
    secrets = {
      "signing-key".extract = ''["synapse"]["signing-key"]'';
      "miniflux" = {
        extract = ''["synapse"]["miniflux"]'';
        format = "json";
      };
      "config" = {
        extract = ''["synapse"]["config"]'';
        format = "yaml";
      };
    };
  };

  systemd.services.synapse = {
    description = "Synapse Matrix server";
    after = [ "network.target" "postgresql.service" "pocket-id.service" "traefik.service" ];
    wants = [ "postgresql.service" "pocket-id.service" "traefik.service" ];
    wantedBy = [ "multi-user.target" ];
    protect.enable = true;
    serviceConfig = {
      ExecStart = "${synapse}/bin/synapse_homeserver --config-path ${settings} --config-path %d/config";
      User = "synapse";
      Restart = "always";
      RestartSec = 5;
      CacheDirectory = "synapse";
      CacheDirectoryMode = "0700";
      WorkingDirectory = "/var/cache/synapse";
      UMask = "0077";
    };
  };

  clement.traefik.dynamic.http = {
    routers.matrix-delegation = {
      rule = "Host(`dubreuil.dev`) && Path(`/.well-known/matrix/client`)";
      service = "synapse";
    };
    routers.matrix-server-delegation = {
      rule = "(Host(`dubreuil.dev`) || Host(`matrix.dubreuil.dev`)) && Path(`/.well-known/matrix/server`)";
      priority = 1000;
      middlewares = [ "matrix-server-delegation" ];
      service = "synapse";
    };
    middlewares.matrix-server-delegation.replacePath.path = "/_synapse/server-delegation";
    routers.synapse = {
      rule = "Host(`matrix.dubreuil.dev`) && (PathPrefix(`/_matrix/`) || PathPrefix(`/_synapse/client/`) || PathPrefix(`/.well-known/matrix/`))";
      service = "synapse";
    };
    services.synapse.loadBalancer.servers = [{ url = "http://[::1]:8008"; }];
  };

  clement.restic.postgresql.databases.synapse.exclude-table-data = [ "public.e2e_one_time_keys_json" ];

  systemd.tmpfiles.rules = [
    "e /var/cache/private/synapse/media - - - 7d -"
  ];
}
