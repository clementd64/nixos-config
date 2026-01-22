{ config, lib, pkgs, ... }:

let
  cfg = config.clement.profile.edge-router;

in with lib; {
  options.clement.profile.edge-router = {
    enable = mkEnableOption "profile edge-router";
  };

  config = mkIf cfg.enable {
    clement.nat64 = {
      enable = true;
      prefix = "2a0c:b641:2b0::64:0:0/96";
      allowed = [
        "2001:bc8:1640:5d6::/64"
        "2001:bc8:710:1198::/64"
      ];
      dns64 = {
        enable = true;
        address = "2a0c:b641:2b0::64:0:53";
      };
    };
  };
}
