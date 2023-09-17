{ config, lib, pkgs, ... }:

let cfg = config.clement.docker;
in with lib; {
  options.clement.docker = {
    enable = mkEnableOption "Enable Docker";

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

        runtimes = {
          runsc = mkIf cfg.gvisor.enable {
            path = "${pkgs.gvisor}/bin/runsc";
            runtimeArgs = [
              "--platform=${cfg.gvisor.platform}"
            ];
          };
        };

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
      };
    };

    environment.systemPackages = mkIf cfg.gvisor.enable [ pkgs.gvisor ];
  };
}
