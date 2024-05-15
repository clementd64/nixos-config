{ pkgs, lib, ... }:
{
  boot.isContainer = true;
  networking.useHostResolvConf = false;
  networking.useDHCP = false;

  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        Address = [ "2a01:4f8:c17:aad:ff00::1/72" "10.0.0.1/24" ];
        Gateway = [ "2a01:4f8:c17:aad:ff00::ffff" "10.0.0.254" ];
      };
    };

    wait-online.anyInterface = true;
  };

  clement.ssh.enable = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:clementd64/nixos-config";
    dates = "02:00";
    randomizedDelaySec = "30min";
  };
  systemd.services.nixos-upgrade.environment.NIX_REMOTE = "daemon";
  environment.sessionVariables.NIX_REMOTE = "daemon";

  # Required for kubelet. Can't use tmpfiles because /dev is ignored.
  boot.postBootCommands = "ln -s /dev/null /dev/kmsg";

  system.stateVersion = "23.11";
}
