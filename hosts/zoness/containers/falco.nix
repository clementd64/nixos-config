{ config, pkgs, ... }:
{
  systemd.network.networks."20-ve-falco" = {
    matchConfig.Name = "ve-falco";
    linkConfig.RequiredForOnline = "no";
    networkConfig = {
      Address = [ "${pkgs.net.genLinkLocal "zoness"}/64" ];
      DHCP = false;
      IPv6AcceptRA = false;
    };
    routes = [
      { Destination = "62.3.50.47/32"; Scope = "link"; }
      { Destination = "${pkgs.net.genIPv6Addr "2a0c:b641:2b2::" "falco"}/128"; GatewayOnLink = true; }
    ];
  };

  systemd.tmpfiles.rules = [
    "d /nix/persist/postgresql 0755 root root - -"
    "d /nix/persist/traefik 0700 root root - -"
    "d /nix/persist/synapse 0700 root root - -"
  ];

  clement.secrets."falco-age-key" = {
    file = ../secrets.json;
    extract = ''["falco_age_key"]'';
    before = [ "container@falco.service" ];
  };

  systemd.services."container@falco".serviceConfig = {
    MemoryMax = "4G";
    CPUQuota = "300%";
  };

  containers.falco = {
    autoStart = true;
    privateNetwork = true;
    extraFlags = [ "--network-veth" ];

    bindMounts = {
      "/nix/key.txt" = {
        hostPath = config.clement.secrets."falco-age-key".path;
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

    config = import ../../falco/system.nix;
  };
}
