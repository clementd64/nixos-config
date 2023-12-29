{ lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig = {
        Address = [
          "194.28.98.82/27"
          "2a0c:b640:8:82::1/48"
        ];
        Gateway = [
          "194.28.98.94"
          "2a0c:b640:8::ffff"
        ];
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJsOQOBnx+1nhll6uLtEUBcaiwSzoj7hEnJrSObVKZaM"
  ];

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    users.clement = {
      files = [
        ".local/share/fish/fish_history"
      ];
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:clementd64/nixos-config";
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "23.11";
}
