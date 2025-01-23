{ pkgs, lib, ... }:
let
  config = {
    DATABASE_URL = "user=miniflux host=/run/postgresql dbname=miniflux sslmode=disable";
    BASE_URL = "https://miniflux.segfault.ovh/";
    RUN_MIGRATIONS = 1;
  };
in {
  systemd.sockets.miniflux = {
    description = "Miniflux socket";
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = "/run/miniflux.sock";
      SocketMode = "0660";
      SocketUser = "miniflux";
      SocketGroup = "cloudflared";
    };
  };

  systemd.services.miniflux = {
    description = "Miniflux service";
    requires = [ "miniflux.socket" "postgresql.service" ];
    after = [ "network.target" "postgresql.service" ];
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
    environment = lib.mapAttrs (_: toString) config;
  };

  environment.systemPackages = [ pkgs.miniflux ];

  users.users.miniflux = {
    home = "/var/empty";
    isSystemUser = true;
    group = "miniflux";
  };
  users.groups.miniflux = {};
}