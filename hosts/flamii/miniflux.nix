{ config, pkgs, lib, ... }:
let
  settings = {
    DATABASE_URL = "host=2001:bc8:710:1198:dc00:ff:fee8:47b9 user=miniflux dbname=miniflux sslmode=verify-ca sslcert=${config.clement.secrets."miniflux-postgresql-tls-cert".path} sslkey=${config.clement.secrets."miniflux-postgresql-tls-key".path} sslrootcert=${config.clement.secrets."miniflux-postgresql-tls-ca".path}";
    LISTEN_ADDR = "[2a0c:b641:2b2::10]:443";
    CERT_FILE = config.clement.secrets."miniflux-tls-cert".path;
    KEY_FILE = config.clement.secrets."miniflux-tls-key".path;
    BASE_URL = "https://miniflux.dubreuil.dev/";
    HTTPS = 1;
    WEBAUTHN = 1;
    RUN_MIGRATIONS = 1;
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
  };

  systemd.services.miniflux = {
    description = "Miniflux service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
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
      NoNewPrivileges = true;
      PrivateTmp = true;
      DevicePolicy = "closed";
      ProtectProc = "invisible";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
      LockPersonality = true;
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