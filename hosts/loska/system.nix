{ lib, pkgs, ... }:
{
  clement.profile.server.enable = true;
  imports = [
    ./hardware.nix
    ./netbox.nix
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
    directories = [
      "/var/lib/rancher/k3s"
    ];
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  clement.kubelet.enableSysctls = true;
  clement.profile.k3s.enable = true;

  environment.systemPackages = [
    pkgs.k3s
    (pkgs.writeShellScriptBin "kubectl" "exec -a $0 ${pkgs.k3s}/bin/k3s $@")
  ];

  system.stateVersion = "23.11";
}
