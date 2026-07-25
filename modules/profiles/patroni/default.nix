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
        caFile = config.clement.credentials."patroni-etcd".secrets."server-ca.pem".path;
        certFile = config.clement.credentials."patroni-etcd".secrets."server-cert.pem".path;
        keyFile = config.clement.credentials."patroni-etcd".secrets."server-key.pem".path;
        peerCaFile = config.clement.credentials."patroni-etcd".secrets."peer-ca.pem".path;
        peerCertFile = config.clement.credentials."patroni-etcd".secrets."peer-cert.pem".path;
        peerKeyFile = config.clement.credentials."patroni-etcd".secrets."peer-key.pem".path;
      };
    };

    clement.credentials."patroni-etcd" = {
      file = cfg.secretsFile;
      before = [ "etcd.service" ];
      secrets = {
        "server-ca.pem".extract = ''["patroni"]["etcd"]["server"]["ca"]'';
        "server-cert.pem".extract = ''["patroni"]["etcd"]["server"]["cert"]'';
        "server-key.pem".extract = ''["patroni"]["etcd"]["server"]["key"]'';
        "peer-ca.pem".extract = ''["patroni"]["etcd"]["peer"]["ca"]'';
        "peer-cert.pem".extract = ''["patroni"]["etcd"]["peer"]["cert"]'';
        "peer-key.pem".extract = ''["patroni"]["etcd"]["peer"]["key"]'';
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
