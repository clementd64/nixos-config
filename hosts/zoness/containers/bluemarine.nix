{ config, pkgs, ... }:
{
  systemd.network.networks."20-ve-bluemarine" = {
    matchConfig.Name = "ve-bluemarine";
    linkConfig.RequiredForOnline = "no";
    networkConfig = {
      Address = [ "${pkgs.net.genLinkLocal "zoness"}/64" ];
      DHCP = false;
      IPv6AcceptRA = false;
    };
    routes = [
      { Destination = "${pkgs.net.genIPv6Addr "2a0c:b641:2b2::" "bluemarine"}/128"; GatewayOnLink = true; }
    ];
  };

  systemd.tmpfiles.rules = [
    "d /nix/persist/postgresql 0755 root root - -"
  ];

  clement.secrets."bluemarine-age-key" = {
    file = ../secrets.json;
    extract = ''["bluemarine_age_key"]'';
    before = [ "container@bluemarine.service" ];
  };

  systemd.services."container@bluemarine".serviceConfig = {
    MemoryMax = "4G";
    CPUQuota = "300%";
  };

  containers.bluemarine = {
    autoStart = true;
    privateNetwork = true;
    extraFlags = [ "--network-veth" ];

    bindMounts = {
      "/nix/key.txt" = {
        hostPath = config.clement.secrets."bluemarine-age-key".path;
        isReadOnly = true;
      };
      "/var/lib/postgresql" = {
        hostPath = "/nix/persist/postgresql";
        isReadOnly = false;
      };
    };

    config = import ../../bluemarine/system.nix;
  };
}
