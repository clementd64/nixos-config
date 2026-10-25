{ pkgs, ... }:
{
  clement.credentials.ntfy = {
    file = ../secrets.json;
    service = "ntfy";
    secrets.config = {
      extract = ''["ntfy"]["config"]'';
      format = "yaml";
    };
  };

  systemd.services.ntfy = {
    description = "ntfy notification service";
    after = [ "network.target" "postgresql.service" ];
    wants = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    protect = {
      enable = true;
      memoryExec = true;
    };
    serviceConfig = {
      ExecStart = "${pkgs.ntfy-sh}/bin/ntfy serve --config %d/config";
      User = "ntfy";
      Restart = "always";
      RestartSec = 5;
    };
    environment = {
      NTFY_DATABASE_URL = "postgresql://ntfy@/ntfy?host=/run/postgresql&sslmode=disable";
      NTFY_BASE_URL = "https://ntfy.dubreuil.dev";
      NTFY_LISTEN_HTTP = "[::1]:2586";
      NTFY_BEHIND_PROXY = "true";
      NTFY_AUTH_DEFAULT_ACCESS = "deny-all";
      NTFY_AUTH_ACCESS = "*:up*:write-only";
      NTFY_ENABLE_LOGIN = "true";
      NTFY_REQUIRE_LOGIN = "true";
      NTFY_ENABLE_SIGNUP = "false";
      NTFY_WEB_ROOT = "disable";
    };
  };

  clement.traefik.dynamic.http = {
    routers.ntfy = {
      rule = "Host(`ntfy.dubreuil.dev`)";
      service = "ntfy";
    };
    services.ntfy.loadBalancer.servers = [{
      url = "http://[::1]:2586";
    }];
  };
}
