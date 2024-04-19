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
  clement.docker.enable = true;
  system.stateVersion = "23.11";
}
