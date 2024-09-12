{ config, lib, pkgs, ... }:

let cfg = config.clement.docker;
in with lib; {
  options.clement.docker = {
    enable = mkEnableOption "Enable Docker";

    pools = {
      ipv4 = {
        subnet = mkOption {
          type = types.str;
          default = "172.17.0.0/16";
        };
        size = mkOption {
          type = types.int;
          default = 24;
        };
      };
      ipv6 = {
        subnet = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        size = mkOption {
          type = types.int;
          default = 64;
        };
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
            base = cfg.pools.ipv4.subnet;
            size = cfg.pools.ipv4.size;
          }
        ] ++ optional (cfg.pools.ipv6.subnet != null) {
          base = cfg.pools.ipv6.subnet;
          size = cfg.pools.ipv6.size;
        };

        ipv6 = cfg.pools.ipv6.subnet != null;
        fixed-cidr = "${builtins.head (splitString "/" cfg.pools.ipv4.subnet)}/${toString cfg.pools.ipv4.size}";
        fixed-cidr-v6 = mkIf (cfg.pools.ipv6.subnet != null) "${builtins.head (splitString "/" cfg.pools.ipv6.subnet)}/${toString cfg.pools.ipv6.size}";

        dns = mkIf config.clement.local.network.enable (
          [
            config.clement.local.network.ipv4
          ] ++ optional (cfg.pools.ipv6.subnet != null) config.clement.local.network.ipv6
        );

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

    clement.local.network.resolved.enable = true;
  };
}
