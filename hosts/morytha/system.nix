{ config, pkgs, lib, ... }:
{
  clement.profile.server.enable = true;

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-ens2" = {
      matchConfig.Name = "ens2";
      networkConfig = {
        DHCP = "yes";
        DNS = "2a0c:b641:2b0::64:0:53";
      };
      ipv6AcceptRAConfig = {
        UseDNS = "no";
      };
    };
  };

  swapDevices = [ {
    device = "/nix/swap";
    size = 2*1024;
  } ];

  services.postgresql = {
    enable = true;
    enableJIT = true;
    package = pkgs.postgresql_18;
    authentication = lib.mkOverride 10 ''
      #type  database  DBuser    address  auth-method
      local  all       postgres           peer
    '';
  };

  clement.traefik = {
    enable = true;
    config = {
      entryPoints = {
        http = {
          address = ":80";
          http.redirections.entryPoint.to = ":443";
        };

        https = {
          address = ":443";
          asDefault = true;
          http.tls = {};
        };
      };
    };

    dynamic = {};
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  system.stateVersion = "25.11";
}
