{ pkgs, lib, ... }:
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
        Address = "2a01:4f8:c013:1614::1/64";
        Gateway = "fe80::1";
      };
    };

    wait-online.anyInterface = true;
  };

  clement.ssh.enable = true;

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

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser   address  auth-method
      local  all       all               trust
      host   all       clement  all      scram-sha-256
      host   hehdon    hehdon   all      scram-sha-256
    '';
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
