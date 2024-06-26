{ config, lib, pkgs, utils, ... }:

with lib;
{
  options.clement.isServer = mkEnableOption "Server configuration";

  config = mkIf config.clement.isServer {
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

    # remove nscd. cache are already disabled by default so running it is useless
    services.nscd.enable = false;
    system.nssModules = lib.mkForce [];
  };
}
