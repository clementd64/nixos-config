{ lib, pkgs, ... }:
{
  imports = [
    ./apps/codex.nix
    ./apps/matrix-rtc.nix
    ./apps/miniflux.nix
    ./apps/ntfy.nix
    ./apps/pocket-id.nix
    ./apps/synapse.nix
  ];

  systemd.network = {
    enable = true;
    networks."40-host0" = {
      matchConfig.Name = "host0";
      networkConfig.Address = [ "62.3.50.47/32" "${pkgs.net.genIPv6Addr "2a0c:b641:2b2::" "falco"}/128" ];
      routes = [
        { Gateway = "194.28.98.82"; GatewayOnLink = true; }
        { Gateway = pkgs.net.genLinkLocal "zoness"; }
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

  system.stateVersion = "26.05";
}
