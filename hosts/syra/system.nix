{ pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;

  networking.wireless.iwd = {
    enable = true;
    settings = {
      Generals = {
        Country = "FR";
      };
    };
  };

  systemd.network = {
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
  };

  networking.firewall = {
    extraCommands = ''
      iptables -A nixos-fw -s 192.168.1.0/24 -p udp --dport 1900 -j ACCEPT
      iptables -A nixos-fw -s 192.168.1.0/24 -p tcp --dport 7879 -j ACCEPT
    '';
  };

  services.resolved.extraConfig = ''
    DNS=2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google 8.8.8.8#dns.google 8.8.4.4#dns.google
  '';

  users.users.clement = {
    # TODO: find a way to manage secret that is installer friendly
    hashedPasswordFile = "/etc/user-password";
    extraGroups = [ "dialout" ];
  };
  nix.settings.trusted-users = [ "clement" ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.pulseaudio = {
    enable = false;
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
      enable = true;
      platform = "kvm";
    };
  };

  clement.xserver.enable = true;
  services.xserver.dpi = 140;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    configPackages = [pkgs.gnome.gnome-session];
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  # TODO: create a module for this
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "wasm32-wasi" ];
  boot.binfmt.registrations.aarch64-linux = {
    interpreter = "${pkgs.qemu-aarch64-static}/bin/qemu-aarch64-static"; # -binfmt-P";
    fixBinary = true;
    matchCredentials = true;
    preserveArgvZero = true;
  };

  system.stateVersion = "23.11";
}
