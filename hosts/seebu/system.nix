{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;
  imports = [
    ./hardware.nix
    ./miniflux.nix
  ];

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2a01:4f8:c013:578a::1/64";
        Gateway = "fe80::1";
      };
    };

    networks."10-enp7s0" = {
      matchConfig.Name = "enp7s0";
      networkConfig.DHCP = "ipv4";
    };
  };

  services.postgresql = {
    enable = true;
    enableJIT = true;
    package = pkgs.postgresql_16;
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser    address  auth-method
      local  all       postgres           peer
      local  miniflux  miniflux           peer
    '';
  };

  services.cloudflared = {
    enable = true;
    tunnels.aegis = {
      credentialsFile = "/run/secrets/cloudflared";
      ingress = {
        "miniflux.segfault.ovh" = "unix:${config.clement.sockets.miniflux.listen}";
      };
      default = "http_status:404";
    };
  };

  clement.secrets.cloudflared = {
    text = ''
      -----BEGIN AGE ENCRYPTED FILE-----
      YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBOM1Y3bkg4bjdPenpIaTRJ
      amREL1p1MGpXZzk1OE5LaW1zdHlZcGJ2NFVvClNIZ1BSY3h0MUw5dnJqU1ZsL3Bn
      VUpJbDhDT0pVZDh6QmdQMnlNS0xWRjQKLS0tIHZsTm1KQlVFR3ZDVThGTnZTQTBC
      SXpqZExjRkhYTkRTODNkdUtLTVRJODQK3GP7GpI6zMUfpGGuCELdpT0o85cmEMdH
      F2CdOWTXmE0EkegkapchY+Gu5OgAmF397Nb0WvrXkfSfDqwMJLh0MWr6t4f2O5CD
      Ha/1wxfiUIVqAOtVGlOP+LUWbyMhnae2XBo/w0o3VzbwprIPOl6tkVCwO7hte8ER
      1G31l/37yPiP3QXRCSUl+WIDK6PKCyA9AynakjITE0z8xYkzpyUdW9FU47qLIifH
      wShARHMN3ZI+INfAtaHBfqowUsjnkNFbxA==
      -----END AGE ENCRYPTED FILE-----
    '';
    user = "cloudflared";
    group = "cloudflared";
    identity = "/nix/agekey";
  };

  system.stateVersion = "24.05";
}
