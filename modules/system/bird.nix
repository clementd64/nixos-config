{ config, lib, pkgs, ... }:

let cfg = config.clement.bird;
in with lib; {
  options.clement.bird = {
    enable = mkEnableOption "Enable bird";

    routerId = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.bird2 = {
      enable = true;
      config = ''
      router id ${cfg.routerId};
      protocol device {}
      '';
    };
  };
}
