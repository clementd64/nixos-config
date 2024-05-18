{ pkgs, lib, ... }:
{
  imports = [
    ../profiles/container-k3s.nix
  ];

  systemd.network = {
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        Address = [ "2a01:4f8:c17:aad:ff00::1/72" "10.0.0.1/24" ];
        Gateway = [ "2a01:4f8:c17:aad:ff00::ffff" "10.0.0.254" ];
      };
    };
  };

  clement.k3s.role = "server";
}
