{ lib, pkgs, ... }:
{
  imports = [
    ./apps/matrix-rtc.nix
    ./apps/synapse.nix
  ];

  systemd.network = {
    enable = true;
    networks."40-host0" = {
      matchConfig.Name = "host0";
      networkConfig.Address = [ "62.3.50.47/32" "${pkgs.net.ip.pepper}/128" ];
      routes = [
        { Gateway = "194.28.98.82"; GatewayOnLink = true; }
        { Gateway = pkgs.net.genLinkLocal "zoness"; }
      ];
    };
  };

  system.stateVersion = "26.05";
}
