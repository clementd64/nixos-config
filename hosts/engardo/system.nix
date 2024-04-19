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

  clement = {
    ssh.enable = true;
    docker = {
      enable = true;
      useResolved.enable = true;
    };

    container = {
      enable = true;
      addresses = [ "2a01:4f8:c17:aad:ff00::ffff/72" "10.0.0.254/24" ];
      containers = {
        runo = {};
      };
    };
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
