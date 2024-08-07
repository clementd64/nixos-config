{ config, lib, pkgs, utils, ... }:

with lib; let
  cfg = config.clement.profile.router;
in {
  options.clement.profile.router = {
    enable = mkEnableOption "router profile";

    bird.config = mkOption {
      type = types.path;
      description = "Bird configuration";
    };
  };

  config = mkIf cfg.enable {
    clement.profile.server.enable = true;

    networking.firewall.checkReversePath = false;

    services.bird2 = {
      enable = true;
      config = strings.concatMapStringsSep "\n" (x: builtins.readFile x) [
        ./common.conf
        cfg.bird.config
      ];
    };
  };
}
