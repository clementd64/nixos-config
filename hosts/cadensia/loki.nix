{ pkgs, ... }:
{
  systemd.services.loki = let
    settings = {
      auth_enabled = false;
      common = {
        ring = {
          kvstore.store = "inmemory";
          instance_interface_names = [];
        };
        replication_factor = 1;
        path_prefix = "\${STATE_DIRECTORY}";
      };
      frontend.address = "127.0.0.1";
      schema_config.configs = [{
        from = "2026-04-30";
        index = {
          prefix = "index_";
          period = "24h";
        };
        object_store = "filesystem";
        schema = "v13";
        store = "tsdb";
      }];
      storage_config.filesystem.directory = "\${STATE_DIRECTORY}/chunks";
    };

    conf = pkgs.writeTextFile {
      name = "loki.json";
      text = builtins.toJSON settings;
      derivationArgs.nativeBuildInputs = [ pkgs.grafana-loki ];
      checkPhase = ''loki -verify-config -config.file "$out"'';
    };
  in {
    description = "Loki service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    protect = {
      enable = true;
      memoryExec = true;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.grafana-loki}/bin/loki -config.expand-env -config.file=${conf}";
      TimeoutSec = 120;
      Restart = "on-failure";
      RestartSec = 2;
      StateDirectory = "loki";
    };
  };
}
