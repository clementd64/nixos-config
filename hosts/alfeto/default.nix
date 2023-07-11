{ ... }:
{
  networking.hostName = "alfeto";

  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/9ffb7b2c-2134-4df8-8be4-7b089997f769";
  };

  networking.wireless.iwd.enable = true;
  networking.useDHCP = false; # handled by systemd
  systemd.network = {
    enable = true;
    networks."10-wlan0" = {
      matchConfig.Name = "wlan0";
      networkConfig.DHCP = "yes";
    };

    networks."10-eth0" = {
      matchConfig.Name = "eth*";
      networkConfig.DHCP = "yes";
    };
  };

  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  clement.docker.enable = true;
  clement.xserver.enable = true;
  services.tailscale.enable = true;

  system.stateVersion = "23.05";
}
