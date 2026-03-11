{ config, lib, pkgs, utils, ... }:

with lib; let
  oci = types.submodule ({ name, config, ... }: {
    options = {
      image = mkOption {
        type = types.str;
        description = "container image to run";
      };

      sha256 = {
        x86_64-linux = mkOption {
          type = types.str;
          description = "sha256 of the OCI image for x86_64-linux";
        };
        aarch64-linux = mkOption {
          type = types.str;
          description = "sha256 of the OCI image for aarch64-linux";
        };
      };

      command = mkOption {
        type = types.str;
        description = "command to run in the container";
      };
    };
  });
in {
  options.clement.oci = mkOption {
    type = types.attrsOf oci;
    default = {};
  };

  config = {
    systemd.services = attrsets.mapAttrs (name: value: {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = value.command;
        Restart = "on-failure";
        RootDirectory = "${pkgs.fetchOCIRootfs { inherit (value) image sha256; }}";
        ReadOnlyPaths = "/";

        DynamicUser = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        DevicePolicy = "closed";
        ProtectProc = "invisible";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        LockPersonality = true;
      };
    }) config.clement.oci;
  };
}
