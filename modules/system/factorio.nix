{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.factorio;
  settingsFormat = pkgs.formats.json {};
  serverSettingsFile = settingsFormat.generate "server-settings.json" cfg.serverSettings;

  whitelistFile = pkgs.writeText "whitelist.json" (builtins.toJSON cfg.whitelist);
  whitelistOption = if builtins.length cfg.whitelist > 0 then "--use-server-whitelist --server-whitelist ${whitelistFile}" else "";
  adminlistFile = pkgs.writeText "adminlist.json" (builtins.toJSON cfg.adminlist);
  adminlistOption = if builtins.length cfg.adminlist > 0 then "--server-adminlist ${adminlistFile}" else "";

  settings = pkgs.writeText "config.ini" ''
    use-system-read-write-data-directories=false
    [path]
    read-data=__PATH__executable__/../usr/share/factorio/data/
    write-data=/var/lib/factorio
    [other]
    check_updates=false
  '';
in {
  options.clement.factorio = {
    enable = mkEnableOption "factorio";
    saveFile = mkOption {
      type = types.str;
    };
    serverSettings = mkOption {
      type = settingsFormat.type;
      default = {};
    };
    whitelist = mkOption {
      type = types.listOf types.str;
      default = [];
    };
    adminlist = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    systemd.services.factorio = {
      description = "Factorio server service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        # Must use private path as symlink is created on start
        ConditionPathExists = "/var/lib/private/factorio/${cfg.saveFile}";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.factorio-headless}/bin/factorio --config ${settings} --server-settings ${serverSettingsFile} --start-server /var/lib/factorio/${cfg.saveFile} ${whitelistOption} ${adminlistOption}";
        Restart = "on-failure";
        Group = "factorio";
        StateDirectory = "factorio";

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
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        LockPersonality = true;
      };
    };

    networking.firewall.allowedUDPPorts = [ 34197 ];
  };
}
