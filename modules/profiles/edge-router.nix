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
      allowed = [];
    };
  };
}
