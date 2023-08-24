{ config, lib, pkgs, ... }:

let cfg = config.clement.traefik;
in with lib; {
  options.clement.traefik = {
    enable = mkEnableOption "Enable Traefik";
  };

  config = mkIf cfg.enable {
    services.traefik = {
      enable = true;
      group = mkIf config.clement.docker.enable "docker";

      staticConfigOptions = {
        entryPoints = {
          http.address = "[::1]:80";
        };

        providers.docker = mkIf config.clement.docker.enable {
          exposedByDefault = false;
        };

        api = {
          dashboard = true;
        };

        accessLog = {};
        metrics.prometheus = {
          manualRouting = true;
        };
      };

      dynamicConfigOptions = {
        http = {
          routers = {
            traefik = {
              rule = "Host(`traefik.localhost`)";
              service = "api@internal";
            };

            traefik-metrics = {
              rule = "Host(`metrics.traefik.localhost`)";
              service = "prometheus@internal";
            };
          };
        };
      };
    };
  };
}
