{ lib, pkgs-unstable, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/6e7a3345-fa2c-419e-95ee-aa51b44d264e";
  };

  networking.wireless.iwd.enable = true;
  networking.useDHCP = false; # handled by systemd
  systemd.network = {
    enable = true;
    networks."10-wlan" = {
      matchConfig.Name = "wlan*";
      networkConfig.DHCP = "yes";
      dhcpV4Config = {
        UseMTU = "yes";
        RouteMetric = 2048;
      };
      ipv6AcceptRAConfig.RouteMetric = 2048;
    };

    networks."10-eth" = {
      matchConfig.Name = "eth*";
      networkConfig.DHCP = "yes";
    };

    wait-online.anyInterface = true;
  };

  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  clement.docker.enable = true;
  clement.traefik.enable = true;
  clement.xserver.enable = true;
  services.xserver.dpi = 140;

  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };

  system.stateVersion = "23.05";
}
