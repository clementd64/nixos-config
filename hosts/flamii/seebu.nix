{ config, pkgs, ... }:
{
  systemd.network.networks."20-ve-seebu" = {
    matchConfig.Name = "ve-seebu";
    linkConfig.RequiredForOnline = "no";
    networkConfig = {
      Address = [ "${pkgs.net.genLinkLocal "flamii"}/64" ];
      DHCP = false;
      IPv6AcceptRA = false;
    };
    routes = [
      { Destination = "62.3.50.47/32"; Scope = "link"; }
      { Destination = "${pkgs.net.genIPv6Addr "2a0c:b641:2b2::" "seebu"}/128"; GatewayOnLink = true; }
    ];
  };

  systemd.tmpfiles.rules = [
    "d /nix/persist/postgresql 0755 root root - -"
    "d /nix/persist/traefik 0700 root root - -"
    "d /nix/persist/synapse 0700 root root - -"
  ];

  clement.secrets."seebu-age-key" = {
    file = ./secrets.json;
    extract = ''["seebu_age_key"]'';
    before = [ "container@seebu.service" ];
  };

  systemd.services."container@seebu".serviceConfig = {
    MemoryMax = "4G";
    CPUQuota = "300%";
  };

  containers.seebu = {
    autoStart = true;
    privateNetwork = true;
    extraFlags = [ "--network-veth" ];

    bindMounts = {
      "/nix/key.txt" = {
        hostPath = config.clement.secrets."seebu-age-key".path;
        isReadOnly = true;
      };
      "/var/lib/postgresql" = {
        hostPath = "/nix/persist/postgresql";
        isReadOnly = false;
      };
      "/var/lib/private/traefik" = {
        hostPath = "/nix/persist/traefik";
        isReadOnly = false;
      };
      "/var/cache/private/synapse" = {
        hostPath = "/nix/persist/synapse";
        isReadOnly = false;
      };
    };

    config = { lib, pkgs, ... }: {
      imports = [
        ./apps/codex.nix
        ./apps/miniflux.nix
        ./apps/ntfy.nix
        ./apps/pocket-id.nix
        ./apps/synapse.nix
      ];

      systemd.network = {
        enable = true;
        networks."40-host0" = {
          matchConfig.Name = "host0";
          networkConfig.Address = [ "62.3.50.47/32" "${pkgs.net.genIPv6Addr "2a0c:b641:2b2::" "seebu"}/128" ];
          routes = [
            { Gateway = "194.28.98.82"; GatewayOnLink = true; }
            { Gateway = pkgs.net.genLinkLocal "flamii"; }
          ];
        };
      };

      networking.firewall.allowedTCPPorts = [ 443 ];

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
      };

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

      clement.restic.secrets = {
        file = ./apps/secrets.json;
        extract = ''["restic"]'';
      };

      system.stateVersion = "26.05";
    };
  };
}
