{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.http2https;
in {
  options.clement.http2https = {
    enable = mkEnableOption "http2https";
  };

  config = mkIf cfg.enable {
    systemd.services.http2https = {
      description = "http to https service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      protect = {
        enable = true;
        memoryExec = true;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.proxy64}/bin/proxy64 http2https";
        Restart = "on-failure";

        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
      };
    };
  };
}
