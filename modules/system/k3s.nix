{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.k3s;

  configPath = pkgs.writeText "config.json" (builtins.toJSON cfg.config);
in {
  options.clement.k3s = {
    enable = mkEnableOption "Enable k3s";

    role = mkOption {
      type = types.enum [ "server" "agent" ];
      description = "Role of the k3s instance";
    };

    config = mkOption {
      type = (pkgs.formats.json {}).type;
      default = {};
      description = "Configuration for k3s";
    };

    manifests = mkOption {
      type = types.attrsOf types.path;
      default = {};
      description = "Extra Auto-Deploying Manifests";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.k3s = {
      description = "k3s";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.k3s}/bin/k3s ${cfg.role} --config ${configPath}";
        KillMode = "process"; # Keep container running. Allow zero-downtime upgrades.
        Delegate = "yes";
        LimitNOFILE = 1048576;
        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        TasksMax = "infinity";
        TimeoutStartSec = 0;
        Restart = "always";
        RestartSec = "5s";
      };
    };

    systemd.tmpfiles.rules = attrsets.mapAttrsToList (name: value:
      "L+ /var/lib/rancher/k3s/server/manifests/${name}.yaml - - - - ${value}"
    ) cfg.manifests;
  };
}
