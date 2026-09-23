{ lib, pkgs, ... }:
{
  imports = [
    ./apps/grafana.nix
    ./apps/miniflux.nix
    ./apps/pocket-id.nix
  ];

  clement.profile.router.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0";

  systemd.network = {
    netdevs."10-as212625" = {
      netdevConfig = {
        Name = "as212625";
        Kind = "vrf";
      };
      vrfConfig.Table = 212625;
    };
    networks."10-as212625" = {
      matchConfig.Name = "as212625";
      routingPolicyRules = [{
        From = "2a0c:b641:2b0:100::/56";
        Table = 212625;
      }];
    };

    networks."10-ens3" = {
      matchConfig = {
        Name = "ens3";
        PermanentMACAddress = "fa:16:3e:96:0c:bf";
      };
      networkConfig = {
        DHCP = "ipv4";
        Address = ["2001:41d0:305:2100::dd40/128"];
        Gateway = ["2001:41d0:305:2100::1"];
        IPv6AcceptRA = false;
      };
      routes = [{
        Destination = "2001:41d0:305:2100::/64";
        Scope = "link";
      }];
    };
  };

  boot.kernel.sysctl."net.ipv4.tcp_l3mdev_accept" = 1;

  clement.profile.mesh.enable = true;
  clement.mesh.vrf = "as212625";

  clement.proxy64.http2https = {
    enable = true;
    acmeWebroot = "/run/acme-challenges";
  };

  clement.wireguard = {
    ekidno = {
      port = 51822;
      endpoint = "ekidno.h.as212625.net:51822";
      presharedKey = ''["wireguard"]["ekidno"]["preshared-key"]'';
      privateKey = ''["wireguard"]["ekidno"]["private-key"]'';
      publicKey = "DMwv37qI9m1VqXKVZVI2c/GUW7B/0Y52qWOU+ZRVsGw=";
      secretsFile = ./secrets.json;
      vrf = "as212625";
    };
    flamii = {
      port = 51823;
      endpoint = "flamii.h.as212625.net:51823";
      presharedKey = ''["wireguard"]["flamii"]["preshared-key"]'';
      privateKey = ''["wireguard"]["flamii"]["private-key"]'';
      publicKey = "Q41VPpfj9todiCdur5fmOfERBlXhcO+75j4lML03hzc=";
      secretsFile = ./secrets.json;
      vrf = "as212625";
    };
  };

  clement.profile.router.bird.config = [ ./bird.conf ];
  clement.profile.router.bird.defines = {
    EKIDNO_IP = pkgs.net.genLinkLocal "ekidno";
    FLAMII_IP = pkgs.net.genLinkLocal "flamii";
  };
  clement.profile.router.bgp.allowedIp = [
    (pkgs.net.genLinkLocal "ekidno")
    (pkgs.net.genLinkLocal "flamii")
  ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    authentication = lib.mkOverride 10 ''
      #type  database  DBuser    address  auth-method
      local  all       postgres           peer
      local  sameuser  all                peer
    '';
    settings.listen_addresses = lib.mkOverride 10 "";
  };

  clement.traefik = {
    enable = true;
    config = {
      entryPoints.ipv4.address = "51.254.131.24:443";
      experimental.otlpLogs = true;
      log.otlp.grpc = {
        endpoint = "127.0.0.1:4317";
        insecure = true;
      };
      accessLog = {
        dualOutput = false;
        otlp.grpc = {
          endpoint = "127.0.0.1:4317";
          insecure = true;
        };
      };
      metrics.otlp.grpc = {
        endpoint = "127.0.0.1:4317";
        insecure = true;
      };
      tracing.otlp.grpc = {
        endpoint = "127.0.0.1:4317";
        insecure = true;
      };
    };
  };

  clement.firewall.dst."tcp:443" = [ "51.254.131.24" ];

  clement.credentials.opentelemetry-collector = {
    file = ./secrets.json;
    service = "opentelemetry-collector";
    secrets = {
      "authorization-token".extract = ''["dash0"]["authorization-token"]'';
    };
  };

  systemd.services.opentelemetry-collector.environment.DASH0_AUTHORIZATION_TOKEN_FILE = "%d/authorization-token";
  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    settings = {
      receivers = {
        otlp = {
          protocols = {
            grpc = {};
            http = {};
          };
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

      processors.batch = {};

      exporters = {
        "otlp_grpc/dash0" = {
          auth.authenticator = "bearertokenauth/dash0";
          endpoint = "ingress.europe-west4.gcp.dash0.com:4317";
        };
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
            processors = [ "batch" ];
            exporters = [ "otlp_grpc/dash0" ];
          };
          logs = {
            receivers = [ "otlp" ];
            processors = [ "batch" ];
            exporters = [ "otlp_grpc/dash0" ];
          };
          traces = {
            receivers = [ "otlp" ];
            processors = [ "batch" ];
            exporters = [ "otlp_grpc/dash0" ];
          };
        };
      };
    };
  };

  system.stateVersion = "26.05";
}
