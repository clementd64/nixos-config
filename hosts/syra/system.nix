{ pkgs, lib, ... }:
{
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
      networkConfig = {
        DHCP = true;
        MulticastDNS = true;
      };
      dhcpV4Config = {
        UseMTU = "yes";
        RouteMetric = 2048;
      };
      ipv6AcceptRAConfig.RouteMetric = 2048;
    };

    networks."10-eth" = {
      matchConfig.Name = "eth*";
      networkConfig = {
        DHCP = true;
        MulticastDNS = true;
      };
    };

    networks."10-en" = {
      matchConfig.Name = "en*";
      networkConfig = {
        DHCP = true;
        MulticastDNS = true;
      };
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
        IPv4Forwarding = true;
      };
      dhcpServerConfig = {
        EmitDNS = true;
        DNS = "1.1.1.1 1.0.0.1";
      };
    };
  };

  networking.firewall = {
    interfaces."wlan0".allowedUDPPorts = [ 67 ];
    extraCommands = ''
      iptables -A nixos-fw -s 192.168.1.0/24 -p udp --dport 1900 -j ACCEPT
      iptables -A nixos-fw -s 192.168.1.0/24 -p tcp --dport 7879 -j ACCEPT
      iptables -A nixos-fw -d 224.0.0.251 -p udp --dport 5353 -j ACCEPT
      ip6tables -A nixos-fw -d FF02::FB -p udp --dport 5353 -j ACCEPT
    '';
  };

  networking.nat = {
    enable = true;
    extraCommands = ''
      iptables -t nat -A nixos-nat-post -s 192.168.200.0/24 -j MASQUERADE
    '';
  };

  services.resolved.settings.Resolve.DNS = "2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google 8.8.8.8#dns.google 8.8.4.4#dns.google";

  clement.wireguard = {
    spacefoot = {
      addresses = [ "10.11.0.1/32" ];
      allowedIps = [ "10.10.0.0/16" ];
      dns = [ "10.10.10.10" ];
      domains = [ "~spacefoot.net." ];
      endpoint = "188.165.39.112:42928";
      presharedKey = ''["wireguard"]["spacefoot"]["preshared-key"]'';
      privateKey = ''["wireguard"]["spacefoot"]["private-key"]'';
      publicKey = "izbe24xKpXV6ZxhwFx0qA7sHNeY062WPfFkh+XpL3Us=";
      secretsFile = ./secrets.json;
    };
    fly = {
      addresses = [ "fdaa:1:70d9:a7b:1596:0:a:102/120" ];
      allowedIps = [ "fdaa:1:70d9::/48" ];
      dns = [ "fdaa:1:70d9::3" ];
      domains = [ "~internal." ];
      endpoint = "cdg1.gateway.6pn.dev:51820";
      privateKey = ''["wireguard"]["fly"]["private-key"]'';
      publicKey = "trM7zOMMKsWHT+F6V08e4e5YVe3VVgf6M8zONd7qzwQ=";
      secretsFile = ./secrets.json;
    };
    proxmox = {
      addresses = [ "10.100.1.1/32" ];
      allowedIps = [ "10.100.0.0/24" ];
      dns = [ "10.100.0.254" ];
      domains = [ "~prox.internal." ];
      endpoint = "51.254.167.78:51820";
      presharedKey = ''["wireguard"]["proxmox"]["preshared-key"]'';
      privateKey = ''["wireguard"]["proxmox"]["private-key"]'';
      publicKey = "t59gHUDoyYqKHIfT/7K9Q7W2rYCrIUCJyHAWQETaIUo=";
      secretsFile = ./secrets.json;
    };
  };

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

  services.pulseaudio = {
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

  services.tailscale.enable = true;
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    configPackages = [pkgs.gnome-session];
  };

  services.power-profiles-daemon.enable = true;
  hardware.fw-fanctrl.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  boot.binfmt = {
    emulatedSystems = [ "aarch64-linux" "wasm32-wasi" ];
    preferStaticEmulators = true;
  };

  system.stateVersion = "23.11";
}
