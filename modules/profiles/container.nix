{ config, lib, pkgs, utils, ... }:

with lib;
{
  config = mkIf config.boot.isContainer {
    users.allowNoPasswordLogin = true;

    # Enable resolved as the host can't be resolved and networkd may be disabled
    services.resolved.enable = mkDefault true;
    # If resolved is enabled, do not use the host's resolv.conf
    networking.useHostResolvConf = lib.mkIf config.services.resolved.enable (lib.mkForce false);

    # systemd.services.nixos-upgrade.environment.NIX_REMOTE = "daemon";
    environment.sessionVariables.NIX_REMOTE = "daemon";
  };
}
