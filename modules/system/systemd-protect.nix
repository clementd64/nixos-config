{ lib, ... }:

with lib; let
  protectDefaults = builtins.mapAttrs (_: mkDefault) {
    DevicePolicy = "closed";
    DynamicUser = true;
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
  };
in {
  options.systemd.services = mkOption {
    type = types.attrsOf (types.submodule ({ config, ... }: {
      options.protect = {
        enable = mkEnableOption "systemd service hardening defaults";
        memoryExec = mkOption {
          type = types.bool;
          default = false;
        };
      };

      config = mkIf config.protect.enable {
        serviceConfig = protectDefaults // optionalAttrs config.protect.memoryExec {
          MemoryDenyWriteExecute = mkDefault true;
        };
      };
    }));
  };
}
