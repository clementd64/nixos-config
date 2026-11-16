{ pkgs, ... }:
let
  settings = (pkgs.formats.json {}).generate "livekit.json" {
    port = 7880;
    bind_addresses = [ pkgs.net.ip.pepper ];
    rtc = {
      node_ip = "62.3.50.47,${pkgs.net.ip.pepper}";
      use_external_ip = false;
      tcp_port = 7881;
      udp_port = 7881;
    };
    room.auto_create = false;
  };
in
{
  clement.credentials = {
    livekit = {
      file = ../secrets.json;
      service = "livekit";
      secrets.keys = {
        extract = ''["matrix-rtc"]["keys"]'';
        format = "yaml";
      };
    };
    lk-jwt-service = {
      file = ../secrets.json;
      service = "lk-jwt-service";
      secrets.keys = {
        extract = ''["matrix-rtc"]["keys"]'';
        format = "yaml";
      };
    };
  };

  systemd.services.livekit = {
    description = "LiveKit MatrixRTC media server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    protect = {
      enable = true;
      memoryExec = true;
    };
    serviceConfig = {
      ExecStart = "${pkgs.livekit}/bin/livekit-server --config ${settings} --key-file %d/keys";
      User = "livekit";
      Restart = "always";
      RestartSec = 5;
      UMask = "0077";
    };
  };

  systemd.services.lk-jwt-service = {
    description = "MatrixRTC LiveKit authorization service";
    after = [ "network-online.target" "livekit.service" ];
    wants = [ "network-online.target" "livekit.service" ];
    wantedBy = [ "multi-user.target" ];
    protect = {
      enable = true;
      memoryExec = true;
    };
    serviceConfig = {
      ExecStart = "${pkgs.lk-jwt-service}/bin/lk-jwt-service";
      User = "lk-jwt-service";
      Restart = "always";
      RestartSec = 5;
      UMask = "0077";
    };
    environment = {
      LIVEKIT_URL = "wss://rtc.matrix.dubreuil.dev/livekit/sfu";
      LIVEKIT_JWT_BIND = "[${pkgs.net.ip.pepper}]:8083";
      LIVEKIT_KEY_FILE = "%d/keys";
      LIVEKIT_FULL_ACCESS_HOMESERVERS = "dubreuil.dev";
    };
  };

  networking.firewall.allowedTCPPorts = [ 7881 ];
  networking.firewall.allowedUDPPorts = [ 7881 ];

  clement.firewall.src = {
    "tcp:7880" = [ "${pkgs.net.ip.zoness}/128" ];
    "tcp:8083" = [ "${pkgs.net.ip.zoness}/128" ];
  };
}
