{ config, lib, pkgs, utils, ... }:

with lib;
{
  options.clement.profile.server.enable = mkEnableOption "server profile";

  config = mkIf config.clement.profile.server.enable {
    # don't start getty on serial consoles
    systemd.services = {
      "getty@".enable = false;
      "serial-getty@".enable = false;
    };

    system.autoUpgrade = {
      enable = true;
      flake = "github:clementd64/nixos-config";
      dates = "02:00";
      randomizedDelaySec = "45min";
      allowReboot = true;
    };

    clement.ssh.enable = true;
  };
}
