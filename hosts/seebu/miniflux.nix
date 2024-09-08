{ pkgs, lib, ... }:
let
  config = {
    LISTEN_ADDR = "/run/miniflux/server.sock";
    DATABASE_URL = "user=miniflux host=/run/postgresql dbname=miniflux sslmode=disable";
    BASE_URL = "https://miniflux.segfault.ovh/";
    DISABLE_SCHEDULER_SERVICE = 1;
    RUN_MIGRATIONS = 1;
  };
in {
  systemd.services.miniflux = {
    description = "Miniflux service";
    requires = [ "postgresql.service" ];
    after = [ "network.target" "postgresql.service" ];
    unitConfig = {
      StopWhenUnneeded = true;
    };
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.miniflux}/bin/miniflux";
      User = "miniflux";
      Group = "miniflux";
      RuntimeDirectory = "miniflux";
      RuntimeDirectoryMode = "0750";
      WatchdogSec = 60;
      WatchdogSignal = "SIGKILL";
      Restart = "always";
      RestartSec = 5;

      PrivateTmp = true;
    };
    environment = lib.mapAttrs (_: toString) config;
  };

  clement.sockets.miniflux = {
    target = config.LISTEN_ADDR;
    user = "miniflux";
    group = "cloudflared";
  };

  systemd.services.miniflux-refresh = {
    description = "Miniflux refresh service";
    requires = [ "postgresql.service" ];
    after = [ "network.target" "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.miniflux}/bin/miniflux -refresh-feeds";
      User = "miniflux";
      Group = "miniflux";

      PrivateTmp = true;
    };
    environment = lib.mapAttrs (_: toString) config;
  };

  systemd.timers.miniflux-refresh = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1h";
      OnUnitActiveSec = "1h";
    };
  };

  systemd.services.miniflux-cleanup = {
    description = "Miniflux cleanup service";
    requires = [ "postgresql.service" ];
    after = [ "network.target" "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.miniflux}/bin/miniflux -run-cleanup-tasks";
      User = "miniflux";
      Group = "miniflux";

      PrivateTmp = true;
    };
    environment = lib.mapAttrs (_: toString) config;
  };

  systemd.timers.miniflux-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "24h";
      OnUnitActiveSec = "24h";
    };
  };

  environment.systemPackages = [ pkgs.miniflux ];

  users.users.miniflux = {
    home = "/var/empty";
    isSystemUser = true;
    group = "miniflux";
  };
  users.groups.miniflux = {};
}