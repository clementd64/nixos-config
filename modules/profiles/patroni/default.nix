{ config, lib, ... }:

with lib; let
  cfg = config.clement.profile.patroni;

  nodes = {
    siren = {
      host = "siren.db.as212625.net";
      address = "2001:bc8:710:1198:dc00:ff:fee8:47b9";
    };
    aion = {
      host = "aion.db.as212625.net";
      address = "2001:bc8:1640:5d6:dc00:ff:fe3b:b327";
    };
    ophion = {
      host = "ophion.db.as212625.net";
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

    clement.patroni = {
      enable = true;
      inherit nodes;
      clientNetworks = [ "2a0c:b641:2b0::/44" ];
      tls = {
        etcd = {
          caFile = config.clement.credentials.patroni.secrets."etcd-ca.pem".path;
          certFile = config.clement.credentials.patroni.secrets."etcd-cert.pem".path;
          keyFile = config.clement.credentials.patroni.secrets."etcd-key.pem".path;
        };
        postgresql = {
          caFile = config.clement.credentials.patroni.secrets."postgresql-ca.pem".path;
          certFile = config.clement.credentials.patroni.secrets."postgresql-server-cert.pem".path;
          keyFile = config.clement.credentials.patroni.secrets."postgresql-server-key.pem".path;
          clientCertFile = config.clement.credentials.patroni.secrets."postgresql-client-cert.pem".path;
          clientKeyFile = config.clement.credentials.patroni.secrets."postgresql-client-key.pem".path;
        };
        restApi = {
          caFile = config.clement.credentials.patroni.secrets."patroni-ca.pem".path;
          certFile = config.clement.credentials.patroni.secrets."patroni-cert.pem".path;
          keyFile = config.clement.credentials.patroni.secrets."patroni-key.pem".path;
        };
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

    clement.credentials.patroni = {
      file = cfg.secretsFile;
      before = [ "patroni.service" ];
      secrets = {
        "etcd-ca.pem".extract = ''["patroni"]["patroni"]["etcd"]["ca"]'';
        "etcd-cert.pem".extract = ''["patroni"]["patroni"]["etcd"]["cert"]'';
        "etcd-key.pem".extract = ''["patroni"]["patroni"]["etcd"]["key"]'';
        "postgresql-ca.pem".extract = ''["patroni"]["postgresql"]["server"]["ca"]'';
        "postgresql-server-cert.pem".extract = ''["patroni"]["postgresql"]["server"]["cert"]'';
        "postgresql-server-key.pem".extract = ''["patroni"]["postgresql"]["server"]["key"]'';
        "postgresql-client-cert.pem".extract = ''["patroni"]["postgresql"]["client"]["cert"]'';
        "postgresql-client-key.pem".extract = ''["patroni"]["postgresql"]["client"]["key"]'';
        "patroni-ca.pem".extract = ''["patroni"]["patroni"]["server"]["ca"]'';
        "patroni-cert.pem".extract = ''["patroni"]["patroni"]["server"]["cert"]'';
        "patroni-key.pem".extract = ''["patroni"]["patroni"]["server"]["key"]'';
      };
    };

    clement.firewall.src = let
      addresses = mapAttrsToList (_: value: value.address) nodes;
    in {
      "tcp:2379" = addresses;
      "tcp:2380" = addresses;
      "tcp:5432" = addresses ++ [ "2a0c:b641:2b0::/44" ];
      "tcp:8008" = addresses;
    };
  };
}
