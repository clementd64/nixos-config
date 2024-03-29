{ pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/6e7a3345-fa2c-419e-95ee-aa51b44d264e";
  };

  networking.wireless.iwd = {
    enable = true;
    settings = {
      Generals = {
        Country = "FR";
      };
    };
  };

  networking.useDHCP = false; # handled by systemd
  systemd.network = {
    enable = true;
    networks."10-wlan" = {
      matchConfig = {
        Name = "wlan*";
        WLANInterfaceType = "!ap";
      };
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

    networks."10-wlan0-ap" = {
      matchConfig = {
        Name = "wlan0";
        WLANInterfaceType = "ap";
      };
      networkConfig = {
        Address = [ "192.168.200.1/24" ];
        DHCPServer = true;
        IPMasquerade = "ipv4";
        IPForward = true;
      };
      dhcpServerConfig = {
        EmitDNS = true;
        DNS = "1.1.1.1 1.0.0.1";
      };
    };

    wait-online.anyInterface = true;
  };

  networking.firewall = {
    interfaces."wlan0".allowedUDPPorts = [ 67 ];
    extraCommands = "iptables -t nat -A POSTROUTING -s 192.168.200.0/24 -j MASQUERADE";
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
    useResolved.enable = true;
  };

  clement.xserver.enable = true;
  services.xserver.dpi = 140;

  services.tailscale.enable = true;
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    configPackages = [pkgs.gnome.gnome-session];
  };

  system.stateVersion = "23.05";
}
