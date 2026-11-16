{ config, pkgs, ... }:
{
  systemd.network.networks."20-ve-pepper" = {
    matchConfig.Name = "ve-pepper";
    linkConfig.RequiredForOnline = "no";
    networkConfig = {
      Address = [ "${pkgs.net.genLinkLocal "zoness"}/64" ];
      DHCP = false;
      IPv6AcceptRA = false;
    };
    routes = [
      { Destination = "62.3.50.47/32"; Scope = "link"; }
      { Destination = "${pkgs.net.ip.pepper}/128"; GatewayOnLink = true; PreferredSource = pkgs.net.ip.zoness; }
    ];
  };

  systemd.tmpfiles.rules = [
    "d /nix/persist/synapse 0700 root root - -"
  ];

  clement.secrets."pepper-age-key" = {
    file = ../secrets.json;
    extract = ''["pepper_age_key"]'';
    before = [ "container@pepper.service" ];
  };

  systemd.services."container@pepper".serviceConfig = {
    MemoryMax = "4G";
    CPUQuota = "300%";
  };

  containers.pepper = {
    autoStart = true;
    privateNetwork = true;
    extraFlags = [ "--network-veth" ];

    bindMounts = {
      "/nix/key.txt" = {
        hostPath = config.clement.secrets."pepper-age-key".path;
        isReadOnly = true;
      };
      "/var/cache/private/synapse" = {
        hostPath = "/nix/persist/synapse";
        isReadOnly = false;
      };
    };

    config = import ../../pepper/system.nix;
  };
}
