{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.etcd;
in {
  options.clement.etcd = {
    enable = mkEnableOption "mutually authenticated etcd member";

    name = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "Unique name of this etcd member.";
    };

    advertiseHost = mkOption {
      type = types.str;
      description = "DNS name advertised for this etcd member.";
    };

    initialCluster = mkOption {
      type = types.listOf types.str;
      description = "Initial etcd cluster members in name=peer-URL form.";
    };

    tls = {
      caFile = mkOption {
        type = types.path;
        description = "CA certificate used to authenticate etcd clients.";
      };

      certFile = mkOption {
        type = types.path;
        description = "Certificate used by this etcd member for client traffic.";
      };

      keyFile = mkOption {
        type = types.path;
        description = "Private key used by this etcd member for client traffic.";
      };

      peerCaFile = mkOption {
        type = types.path;
        description = "CA certificate used to authenticate etcd peers.";
      };

      peerCertFile = mkOption {
        type = types.path;
        description = "Certificate used by this etcd member for peer traffic.";
      };

      peerKeyFile = mkOption {
        type = types.path;
        description = "Private key used by this etcd member for peer traffic.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.etcd = {
      description = "etcd key-value store";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.RequiresMountsFor = "/var/lib/private/etcd";

      protect.enable = true;

      environment = {
        ETCD_NAME = cfg.name;
        ETCD_DATA_DIR = "%S/etcd";
        ETCD_ADVERTISE_CLIENT_URLS = "https://${cfg.advertiseHost}:2379";
        ETCD_LISTEN_CLIENT_URLS = "https://[::]:2379";
        ETCD_LISTEN_PEER_URLS = "https://[::]:2380";
        ETCD_INITIAL_ADVERTISE_PEER_URLS = "https://${cfg.advertiseHost}:2380";
        ETCD_INITIAL_CLUSTER = concatStringsSep "," cfg.initialCluster;

        ETCD_CLIENT_CERT_AUTH = "true";
        ETCD_TRUSTED_CA_FILE = "%d/server-ca.pem";
        ETCD_CERT_FILE = "%d/server-cert.pem";
        ETCD_KEY_FILE = "%d/server-key.pem";

        ETCD_PEER_CLIENT_CERT_AUTH = "true";
        ETCD_PEER_TRUSTED_CA_FILE = "%d/peer-ca.pem";
        ETCD_PEER_CERT_FILE = "%d/peer-cert.pem";
        ETCD_PEER_KEY_FILE = "%d/peer-key.pem";

        ETCD_AUTO_COMPACTION_MODE = "periodic";
        ETCD_AUTO_COMPACTION_RETENTION = "10h";
      };

      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.etcd}/bin/etcd";
        User = "etcd";
        DynamicUser = true;
        StateDirectory = "etcd";
        LoadCredential = [
          "server-ca.pem:${cfg.tls.caFile}"
          "server-cert.pem:${cfg.tls.certFile}"
          "server-key.pem:${cfg.tls.keyFile}"
          "peer-ca.pem:${cfg.tls.peerCaFile}"
          "peer-cert.pem:${cfg.tls.peerCertFile}"
          "peer-key.pem:${cfg.tls.peerKeyFile}"
        ];
        Restart = "always";
        RestartSec = "30s";
        LimitNOFILE = 40000;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/private 0700 root root -"
    ];

    environment.systemPackages = [ pkgs.etcd ];
  };
}
