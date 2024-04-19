{ config, lib, pkgs, ... }:

let cfg = config.clement.ssh;
in with lib; {
  options.clement.ssh = {
    enable = mkEnableOption "Enable ssh server";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
    users.users.clement.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJsOQOBnx+1nhll6uLtEUBcaiwSzoj7hEnJrSObVKZaM clement.dubreuil@spacefoot.com"
    ];
  };
}