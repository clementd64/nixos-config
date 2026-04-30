{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.traefik;
  settingsFormat = pkgs.formats.json {};

  staticConfigFile = settingsFormat.generate "config.json" cfg.config;
  dynamicConfigFile = settingsFormat.generate "dynamic.json" cfg.dynamic;
in {
  options.clement.traefik = {
    enable = mkEnableOption "traefik";
    enableDocker = mkOption {
      type = types.bool;
      default = true;
    };

    config = mkOption {
      type = settingsFormat.type;
      default = {};
    };

    dynamic = mkOption {
      type = types.nullOr settingsFormat.type;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    clement.traefik.config.providers = {
      docker = mkIf (config.clement.docker.enable && cfg.enableDocker) {};
      file = mkIf (cfg.dynamic != null) {
        filename = dynamicConfigFile;
      };
    };

    systemd.services.traefik = {
      description = "Traefik service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      protect = {
        enable = true;
        memoryExec = true;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.traefik}/bin/traefik --configfile=${staticConfigFile}";
        Restart = "on-failure";

        SupplementaryGroups = mkIf (config.clement.docker.enable && cfg.enableDocker) "docker";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        LimitNPROC = 64;
        LimitNOFILE = 1048576;
      };
    };
  };
}
