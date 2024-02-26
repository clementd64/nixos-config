{ lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;

  networking.useDHCP = false; # handled by systemd
  systemd.network = {
    enable = true;
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2a01:4f8:c17:aad::1/64";
        Gateway = "fe80::1";
      };
    };

    wait-online.anyInterface = true;
  };

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

  services.tailscale.enable = true;

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/tailscale"
      "/var/lib/docker"
    ];
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    users.clement = {
      files = [
        ".local/share/fish/fish_history"
      ];
    };
  };

  clement.docker = {
    enable = true;
    useResolved.enable = true;
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:clementd64/nixos-config";
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  system.stateVersion = "23.11";
}
