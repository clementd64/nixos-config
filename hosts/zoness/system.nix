{ pkgs, lib, ... }:
{
  imports = [
    ./containers/bluemarine.nix
    ./containers/falco.nix
    ./containers/pepper.nix
  ];

  clement.profile.as212625.enable = true;
  clement.opentelemetry = {
    enable = true;
    secretsFile = ./secrets.json;
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";

  systemd.network = {
    networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig = {
        Address = [
          "194.28.98.82/27"
          "2a0c:b640:8:82::1/48"
        ];
        Gateway = [ "194.28.98.94" ];
        IPv6AcceptRA = false;
      };
    };
  };

  clement.local.addresses = [
    "${pkgs.net.ip.zoness}/128"
    "2a0c:b641:2b2::1/128"
  ];

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    directories = [
      { directory = "/var/lib/private/traefik"; mode = "0700"; }
    ];
  };

  clement.profile.router.bird.config = [
    ../../modules/profiles/router/servperso.conf
    ./bird.conf
  ];
  clement.profile.router.bgp.allowedIp = [
    "2a0c:b640:8::ffff" # Servperso
  ];
  clement.profile.as212625.dns.bind = [
    "194.28.98.82"
    "2a0c:b641:2b2::1"
  ];

  clement.wireguard = {
    home = {
      addresses = [ "fe80::1/64" ];
      port = 51820;
      presharedKey = ''["wireguard"]["home"]["preshared-key"]'';
      privateKey = ''["wireguard"]["home"]["private-key"]'';
      publicKey = "fL2bCOcZFXJeUtE4372q1URCIToWgj0H0qkyTDIv0Qc=";
      secretsFile = ./secrets.json;
    };
    pixel = {
      allowedIps = [ "2a0c:b641:2b2::9/128" ];
      port = 51821;
      presharedKey = ''["wireguard"]["pixel"]["preshared-key"]'';
      privateKey = ''["wireguard"]["pixel"]["private-key"]'';
      publicKey = "Q7mUDHH4ksk/2BCQHIWso94JIvX+BcQJQhs+qluBIyI=";
      secretsFile = ./secrets.json;
    };
  };

  clement.traefik = {
    enable = true;
    config = {
      entryPoints = {
        https = {
          address = ":443";
          http.tls.certResolver = "letsencrypt";
        };
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "clement@dubreuil.dev";
        storage = "/var/lib/traefik/acme.json";
        profile = "shortlived";
        certificatesDuration = 160;
        keyType = "EC256";
        tlsChallenge = {};
      };

      log.level = "INFO";
    };

    dynamic.http = {
      routers.miniflux = {
        rule = "Host(`miniflux.dubreuil.dev`) && !Path(`/metrics`)";
        service = "miniflux";
      };
      services.miniflux.loadBalancer.servers = [{
        url = "http://[${pkgs.net.ip.falco}]:8081";
      }];

      routers.codex = {
        rule = "Host(`codex.dubreuil.dev`)";
        service = "codex";
      };
      services.codex.loadBalancer.servers = [{
        url = "http://[${pkgs.net.ip.falco}]:8082";
      }];

      routers.ntfy = {
        rule = "Host(`ntfy.dubreuil.dev`)";
        service = "ntfy";
      };
      services.ntfy.loadBalancer.servers = [{
        url = "http://[${pkgs.net.ip.falco}]:2586";
      }];

      routers.pocket-id = {
        rule = "Host(`id.dubreuil.dev`)";
        service = "pocket-id";
      };
      services.pocket-id.loadBalancer.servers = [{
        url = "http://[${pkgs.net.ip.falco}]:1411";
      }];

      routers.matrix-delegation = {
        rule = "Host(`dubreuil.dev`) && Path(`/.well-known/matrix/client`)";
        service = "synapse";
      };
      routers.matrix-server-delegation = {
        rule = "(Host(`dubreuil.dev`) || Host(`matrix.dubreuil.dev`)) && Path(`/.well-known/matrix/server`)";
        priority = 1000;
        middlewares = [ "matrix-server-delegation" ];
        service = "synapse";
      };
      middlewares.matrix-server-delegation.replacePath.path = "/_synapse/server-delegation";
      routers.synapse = {
        rule = "Host(`matrix.dubreuil.dev`) && (PathPrefix(`/_matrix/`) || PathPrefix(`/_synapse/client/`) || PathPrefix(`/.well-known/matrix/`))";
        service = "synapse";
      };
      services.synapse.loadBalancer.servers = [{ url = "http://[${pkgs.net.ip.pepper}]:8008"; }];

      routers.matrix-rtc-jwt = {
        rule = "Host(`rtc.matrix.dubreuil.dev`) && (Path(`/livekit/jwt`) || PathPrefix(`/livekit/jwt/`))";
        middlewares = [ "matrix-rtc-jwt" ];
        service = "lk-jwt-service";
      };
      middlewares.matrix-rtc-jwt.stripPrefix.prefixes = [ "/livekit/jwt" ];
      services.lk-jwt-service.loadBalancer.servers = [{ url = "http://[${pkgs.net.ip.pepper}]:8083"; }];

      routers.matrix-rtc-sfu = {
        rule = "Host(`rtc.matrix.dubreuil.dev`) && (Path(`/livekit/sfu`) || PathPrefix(`/livekit/sfu/`))";
        middlewares = [ "matrix-rtc-sfu" ];
        service = "livekit";
      };
      middlewares.matrix-rtc-sfu.stripPrefix.prefixes = [ "/livekit/sfu" ];
      services.livekit.loadBalancer.servers = [{ url = "http://[${pkgs.net.ip.pepper}]:7880"; }];
    };
  };

  clement.firewall.dst."tcp:443" = [ "${pkgs.net.ip.zoness}/128" "194.28.98.82/32" ];

  system.stateVersion = "23.11";
}
