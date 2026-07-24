{ config, lib, ... }:

with lib; let
  cfg = config.clement.profile.patroni;

  nodes = {
    siren = {
      host = "siren.h.as212625.net";
      address = "2001:bc8:710:1198:dc00:ff:fee8:47b9";
    };
    aion = {
      host = "aion.h.as212625.net";
      address = "2001:bc8:1640:5d6:dc00:ff:fe3b:b327";
    };
    ophion = {
      host = "ophion.h.as212625.net";
      address = "2001:bc8:1d90:1a1:dc00:ff:fe2d:ee0f";
    };
  };
in {
  options.clement.profile.patroni = {
    enable = mkEnableOption "Patroni profile";

    secretsFile = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = builtins.hasAttr config.networking.hostName nodes;
      message = "clement.profile.patroni: networking.hostName '${config.networking.hostName}' is not present in the Patroni nodes registry";
    }];

    clement.etcd = {
      enable = true;
      name = config.networking.hostName;
      advertiseHost = nodes."${config.networking.hostName}".host;
      initialCluster = mapAttrsToList (name: value: "${name}=https://${value.host}:2380") nodes;
      tls = {
        caFile = config.clement.secrets."patroni-etcd-server-ca".path;
        certFile = config.clement.secrets."patroni-etcd-server-cert".path;
        keyFile = config.clement.secrets."patroni-etcd-server-key".path;
        peerCaFile = config.clement.secrets."patroni-etcd-peer-ca".path;
        peerCertFile = config.clement.secrets."patroni-etcd-peer-cert".path;
        peerKeyFile = config.clement.secrets."patroni-etcd-peer-key".path;
      };
    };

    clement.secrets = {
      patroni-etcd-server-ca = {
        file = cfg.secretsFile;
        extract = ''["patroni"]["etcd"]["server"]["ca"]'';
        before = [ "etcd.service" ];
      };
      patroni-etcd-server-cert = {
        file = cfg.secretsFile;
        extract = ''["patroni"]["etcd"]["server"]["cert"]'';
        before = [ "etcd.service" ];
      };
      patroni-etcd-server-key = {
        file = cfg.secretsFile;
        extract = ''["patroni"]["etcd"]["server"]["key"]'';
        before = [ "etcd.service" ];
      };
      patroni-etcd-peer-ca = {
        file = cfg.secretsFile;
        extract = ''["patroni"]["etcd"]["peer"]["ca"]'';
        before = [ "etcd.service" ];
      };
      patroni-etcd-peer-cert = {
        file = cfg.secretsFile;
        extract = ''["patroni"]["etcd"]["peer"]["cert"]'';
        before = [ "etcd.service" ];
      };
      patroni-etcd-peer-key = {
        file = cfg.secretsFile;
        extract = ''["patroni"]["etcd"]["peer"]["key"]'';
        before = [ "etcd.service" ];
      };
    };

    clement.firewall.src = let
      addresses = mapAttrsToList (_: value: value.address) nodes;
    in {
      "tcp:2379" = addresses;
      "tcp:2380" = addresses;
    };
  };
}
