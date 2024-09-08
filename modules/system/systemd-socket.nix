{ config, lib, pkgs, ... }:

with lib; {
  options.clement.sockets = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        target = mkOption {
          type = types.str;
        };

        listen = mkOption {
          type = types.str;
          default = "/run/socket/${name}.sock";
        };

        user = mkOption {
          type = types.str;
          default = "root";
        };

        group = mkOption {
          type = types.str;
          default = "root";
        };

        mode = mkOption {
          type = types.str;
          default = "0660";
        };
      };
    }));
    default = {};
  };

  config.systemd = mkMerge (attrsets.mapAttrsToList (name: value: {
    services."${name}".unitConfig.StopWhenUnneeded = true;

    sockets."${name}-socket" = {
      description = "${name} socket";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = value.listen;
        SocketMode = value.mode;
        SocketUser = value.user;
        SocketGroup = value.group;
      };
    };

    services."${name}-socket" = {
      description = "${name} socket";
      after = [ "network.target" "${name}-socket.socket" "${name}.service" ];
      bindsTo = [ "${name}-socket.socket" "${name}.service" ];
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=1m ${value.target}";
        User = value.user;
        Group = value.group;
        PrivateTmp = true;
      };
    };
  }) config.clement.sockets);
}
