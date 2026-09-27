{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.opentelemetry;
in {
  options.clement.opentelemetry = {
    enable = mkEnableOption "OpenTelemetry collector";

    secretsFile = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    clement.credentials.opentelemetry-collector = {
      file = cfg.secretsFile;
      service = "opentelemetry-collector";
      secrets."authorization-token".extract = ''["dash0"]["authorization-token"]'';
    };

    systemd.services.opentelemetry-collector.environment.DASH0_AUTHORIZATION_TOKEN_FILE = "%d/authorization-token";

    services.opentelemetry-collector = {
      enable = true;
      package = pkgs.opentelemetry-collector-contrib;
      settings = {
        receivers = {
          otlp.protocols = {
            grpc = {};
            http = {};
          };

          host_metrics = {
            collection_interval = "60s";
            scrapers = {
              cpu.metrics."system.cpu.utilization".enabled = true;
              disk = {};
              filesystem.metrics."system.filesystem.utilization".enabled = true;
              load = {};
              memory.metrics."system.memory.utilization".enabled = true;
              network = {};
              paging = {};
              processes = {};
            };
          };
        };

        processors = {
          resourcedetection = {
            detectors = [ "env" "system" ];
            system.hostname_sources = [ "os" ];
          };
        };

        exporters."otlp_grpc/dash0" = {
          auth.authenticator = "bearertokenauth/dash0";
          endpoint = "ingress.europe-west4.gcp.dash0.com:4317";
        };

        extensions."bearertokenauth/dash0" = {
          scheme = "Bearer";
          filename = "\${env:DASH0_AUTHORIZATION_TOKEN_FILE}";
        };

        service = {
          extensions = [ "bearertokenauth/dash0" ];
          pipelines = {
            metrics = {
              receivers = [ "otlp" "host_metrics" ];
              processors = [ "resourcedetection" ];
              exporters = [ "otlp_grpc/dash0" ];
            };
            logs = {
              receivers = [ "otlp" ];
              exporters = [ "otlp_grpc/dash0" ];
            };
            traces = {
              receivers = [ "otlp" ];
              exporters = [ "otlp_grpc/dash0" ];
            };
          };
        };
      };
    };
  };
}
