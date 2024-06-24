{ config, lib, pkgs, ... }:

let cfg = config.clement.docker;
in with lib; {
  options.clement.docker = {
    enable = mkEnableOption "Enable Docker";

    useResolved = {
      enable = mkEnableOption "Use systemd-resolved stub resolver";
      ipv4 = mkOption {
        type = types.str;
        default = "192.168.192.168";
      };
      ipv6 = mkOption {
        type = types.str;
        default = "fd55:d249:5b9d:4dce:64fd:f7c3:cf53:9905";
      };
    };

    gvisor = {
      enable = mkEnableOption "Enable gVisor";

      platform = mkOption {
        type = types.str;
        default = "systrap";
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.clement.extraGroups = [ "docker" ];

    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        log-driver = "journald";
        exec-opts = [
          "native.cgroupdriver=systemd"
        ];

        features = {
          buildkit = true;
        };

        default-address-pools = [
          {
            base = "172.17.0.0/16";
            size = 24;
          }
        ];
        bip = "172.17.0.1/24";

        dns = mkIf cfg.useResolved.enable [
          cfg.useResolved.ipv4
          # cfg.useResolved.ipv6
        ];

        runtimes = {
          runsc = mkIf cfg.gvisor.enable {
            path = "${pkgs.gvisor}/bin/runsc";
            runtimeArgs = [
              "--platform=${cfg.gvisor.platform} --network=host"
            ];
          };
        };
      };

      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    systemd.network = mkIf cfg.useResolved.enable {
      netdevs."20-dockerdns" = {
        netdevConfig = {
          Name = "dockerdns";
          Kind = "dummy";
        };
      };

      networks."20-dockerdns" = {
        matchConfig.Name = "dockerdns";
        networkConfig = {
          Address = [
            "${cfg.useResolved.ipv4}/32"
            "${cfg.useResolved.ipv6}/128"
          ];
        };
      };
    };

    services.resolved.extraConfig = mkIf cfg.useResolved.enable ''
      DNSStubListenerExtra=${cfg.useResolved.ipv4}
      DNSStubListenerExtra=${cfg.useResolved.ipv6}
    '';

    networking.firewall.extraCommands = mkIf cfg.useResolved.enable ''
      iptables -A nixos-fw -p udp --dport 53 -s 172.17.0.0/16 -j ACCEPT
      iptables -A nixos-fw -p tcp --dport 53 -s 172.17.0.0/16 -j ACCEPT
    '';
  };
}
