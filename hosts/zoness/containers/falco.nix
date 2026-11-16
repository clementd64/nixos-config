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
      { Destination = "${pkgs.net.ip.falco}/128"; GatewayOnLink = true; PreferredSource = pkgs.net.ip.zoness; }
    ];
  };

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
    };

    config = import ../../falco/system.nix;
  };
}
