{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.k3s;

  # TODO
  k3sConfig = {
    base = {};
    server = {
      disable = [ "servicelb" "traefik" "local-storage" ];
      disable-helm-controller = true;
      secrets-encryption = true;
    };
    agent = {};
  };

  mergeConfig = attrsets.mergeAttrsList (
    [k3sConfig.base]
    ++ optional (cfg.role == "server") k3sConfig.server
    ++ optional (cfg.role == "agent") k3sConfig.agent
    ++ [cfg.config]
  );

  configPath = pkgs.writeText "config.json" (builtins.toJSON mergeConfig);
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
  };
}
