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
      secrets."uptrace-dsn".extract = ''["uptrace_dsn"]'';
    };

    systemd.services.opentelemetry-collector.environment.UPTRACE_DSN_FILE = "%d/uptrace-dsn";

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
              cpu = {};
              disk = {};
              filesystem = {};
              load = {};
              memory = {};
              network = {};
              paging = {};
              processes = {};
            };
          };
        };

        processors = {
          memory_limiter = {
            check_interval = "1s";
            limit_mib = 512;
            spike_limit_mib = 128;
          };

          resourcedetection = {
            detectors = [ "env" "system" ];
            system.hostname_sources = [ "os" ];
          };

          cumulativetodelta = {};

          batch = {
            send_batch_size = 10000;
            timeout = "10s";
          };
        };

        exporters."otlp_grpc/uptrace" = {
          endpoint = "https://otlp.uptrace.dev:4317";
          headers.uptrace-dsn = "\${file:\${env:UPTRACE_DSN_FILE}}";
        };

        service = {
          pipelines = {
            metrics = {
              receivers = [ "otlp" "host_metrics" ];
              processors = [ "memory_limiter" "resourcedetection" "cumulativetodelta" "batch" ];
              exporters = [ "otlp_grpc/uptrace" ];
            };
            logs = {
              receivers = [ "otlp" ];
              processors = [ "memory_limiter" "batch" ];
              exporters = [ "otlp_grpc/uptrace" ];
            };
            traces = {
              receivers = [ "otlp" ];
              processors = [ "memory_limiter" "batch" ];
              exporters = [ "otlp_grpc/uptrace" ];
            };
          };
        };
      };
    };
  };
}
