{ lib, ... }:
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

    networks."10-en" = {
      matchConfig.Name = "en*";
      networkConfig.DHCP = "yes";
    };

    wait-online.anyInterface = true;
  };

  services.resolved.extraConfig = ''
    DNS=2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google 8.8.8.8#dns.google 8.8.4.4#dns.google
  '';

  users.users.clement = {
    # TODO: find a way to manage secret that is installer friendly
    hashedPasswordFile = "/etc/user-password";
  };

  hardware.pulseaudio = {
    enable = true;
    # Auto switch between A2DP and HFP to make airpods mic working
    extraConfig = ''
      .ifexists module-bluetooth-policy.so
      .nofail
      unload-module module-bluetooth-policy
      .fail
      load-module module-bluetooth-policy auto_switch=2
      .endif
    '';
  };
  hardware.bluetooth.enable = true;

  clement.docker = {
    enable = true;
    gvisor = {
      enable = false;
      platform = "kvm";
    };
  };

  clement.xserver.enable = true;
  services.xserver.dpi = 140;

  services.tailscale.enable = true;

  system.stateVersion = "23.05";
}
