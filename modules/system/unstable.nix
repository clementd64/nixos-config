{ config, lib, pkgs, ... }:

let cfg = config.clement.unstable;
in with lib; {
  options.clement.unstable = {
    enable = mkEnableOption "Unstable";
  };

  config = mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
