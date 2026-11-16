{ lib, pkgs, ... }:
{
  imports = [
    ./apps/codex.nix
    ./apps/miniflux.nix
    ./apps/ntfy.nix
    ./apps/pocket-id.nix
  ];

  systemd.network = {
    enable = true;
    networks."40-host0" = {
      matchConfig.Name = "host0";
      networkConfig.Address = [ "${pkgs.net.ip.falco}/128" ];
      routes = [
        { Gateway = pkgs.net.genLinkLocal "zoness"; }
      ];
    };
  };

  system.stateVersion = "26.05";
}
