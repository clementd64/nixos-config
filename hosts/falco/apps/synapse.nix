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
        host = "db.as212625.net";
        user = "synapse";
        dbname = "synapse";
        sslmode = "verify-full";
        sslcert = "/run/credentials/synapse.service/postgresql-tls-cert.pem";
        sslkey = "/run/credentials/synapse.service/postgresql-tls-key.pem";
        sslrootcert = "/run/credentials/synapse.service/postgresql-tls-ca.pem";
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

    # Call
    extra_well_known_client_content."org.matrix.msc4143.rtc_foci" = [{
      type = "livekit";
      livekit_service_url = "https://rtc.matrix.dubreuil.dev/livekit/jwt";
    }];
    experimental_features = {
      msc4143_enabled = true;
      msc4222_enabled = true;
    };
    matrix_rtc.transports = [{
      type = "livekit";
      livekit_service_url = "https://rtc.matrix.dubreuil.dev/livekit/jwt";
    }];
    max_event_delay_duration = "24h";
    rc_message = { per_second = 0.5; burst_count = 30; };
    rc_delayed_event_mgmt = { per_second = 1; burst_count = 20; };
  };
in
{
  clement.credentials.synapse = {
    file = ../secrets.json;
    service = "synapse";
    secrets = {
      "postgresql-tls-ca.pem".extract = ''["synapse"]["postgresql"]["ca"]'';
      "postgresql-tls-cert.pem".extract = ''["synapse"]["postgresql"]["cert"]'';
      "postgresql-tls-key.pem".extract = ''["synapse"]["postgresql"]["key"]'';
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
    after = [ "network.target" "pocket-id.service" "traefik.service" ];
    wants = [ "pocket-id.service" "traefik.service" ];
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

  systemd.tmpfiles.rules = [
    "e /var/cache/private/synapse/media - - - 7d -"
  ];
}
