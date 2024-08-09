{ config, lib, pkgs, utils, ... }:

with lib;
{
  config = mkIf config.boot.isContainer {
    users.allowNoPasswordLogin = true;

    networking.useHostResolvConf = lib.mkIf config.services.resolved.enable (lib.mkForce false);

    systemd.services.nixos-upgrade.environment.NIX_REMOTE = "daemon";
    environment.sessionVariables.NIX_REMOTE = "daemon";
  };
}
