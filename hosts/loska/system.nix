{ lib, pkgs, ... }:
{
  clement.profile.server.enable = true;
  imports = [
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;

  systemd.network = {
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        Address = "2a01:4f8:c17:aad::1/64";
        Gateway = "fe80::1";
      };
    };

    networks."10-enp7s0" = {
      matchConfig.Name = "enp7s0";
      networkConfig.DHCP = "ipv4";
    };
  };

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  clement.kubelet.sysctls.enable = true;

  system.stateVersion = "23.11";
}
