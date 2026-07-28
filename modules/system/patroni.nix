{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.patroni;

  nodes = attrValues cfg.nodes;

  defaultSettings = {
    name = config.networking.hostName;
    scope = "patroni";

    restapi = {
      listen = "[::]:8008";
      connect_address = "${cfg.nodes."${config.networking.hostName}".host}:8008";
      certfile = "/run/credentials/patroni.service/patroni-cert.pem";
      keyfile = "/run/credentials/patroni.service/patroni-key.pem";
      cafile = "/run/credentials/patroni.service/patroni-ca.pem";
      verify_client = "required";
    };

    ctl = {
      cacert = "/run/credentials/patroni.service/patroni-ca.pem";
      certfile = "/run/credentials/patroni.service/patroni-cert.pem";
      keyfile = "/run/credentials/patroni.service/patroni-key.pem";
    };

    etcd3 = {
      hosts = map (node: "${node.host}:2379") nodes;
      protocol = "https";
      cacert = "/run/credentials/patroni.service/etcd-ca.pem";
      cert = "/run/credentials/patroni.service/etcd-cert.pem";
      key = "/run/credentials/patroni.service/etcd-key.pem";
    };

    bootstrap = {
      dcs = {
        ttl = 30;
        loop_wait = 10;
        retry_timeout = 10;
        maximum_lag_on_failover = 1048576;
        postgresql.use_slots = true;
      };

      initdb = [
        { encoding = "UTF8"; }
        "data-checksums"
      ];
    };

    postgresql = {
      listen = "[::]:5432";
      connect_address = "${cfg.nodes."${config.networking.hostName}".host}:5432";
      data_dir = "/var/lib/postgresql/data";
      bin_dir = "${pkgs.postgresql_18}/bin";
      pgpass = "/var/lib/postgresql/patroni/pgpass";
      use_pg_rewind = true;
      use_slots = true;
      use_unix_socket = true;
      use_unix_socket_repl = true;

      authentication = {
        replication = {
          username = "replication";
          sslmode = "verify-full";
          sslrootcert = "/run/credentials/patroni.service/postgresql-ca.pem";
          sslcert = "/run/credentials/patroni.service/postgresql-client-cert.pem";
          sslkey = "/run/credentials/patroni.service/postgresql-client-key.pem";
        };
        rewind = {
          username = "rewind";
          sslmode = "verify-full";
          sslrootcert = "/run/credentials/patroni.service/postgresql-ca.pem";
          sslcert = "/run/credentials/patroni.service/postgresql-client-cert.pem";
          sslkey = "/run/credentials/patroni.service/postgresql-client-key.pem";
        };
        superuser = {
          username = "postgres";
          sslmode = "verify-full";
          sslrootcert = "/run/credentials/patroni.service/postgresql-ca.pem";
          sslcert = "/run/credentials/patroni.service/postgresql-client-cert.pem";
          sslkey = "/run/credentials/patroni.service/postgresql-client-key.pem";
        };
      };

      parameters = {
        ssl = "on";
        ssl_ca_file = "/run/credentials/patroni.service/postgresql-ca.pem";
        ssl_cert_file = "/run/credentials/patroni.service/postgresql-server-cert.pem";
        ssl_key_file = "/run/credentials/patroni.service/postgresql-server-key.pem";
        ssl_min_protocol_version = "TLSv1.3";
        unix_socket_directories = "/run/postgresql";
      };

      pg_hba = [
        "local all postgres peer map=patroni"
        "local replication replication peer map=patroni"
      ] ++ concatMap (node: [
        "hostssl replication replication ${node.address}/128 cert map=patroni"
        "hostssl all rewind ${node.address}/128 cert map=patroni"
        "hostssl all postgres ${node.address}/128 cert map=patroni"
      ]) nodes ++ map (network:
        "hostssl all postgres ${network} cert"
      ) cfg.clientNetworks;

      pg_ident = [
        "patroni patroni postgres"
        "patroni patroni replication"
      ] ++ concatMap (node: [
        "patroni ${node.host} replication"
        "patroni ${node.host} rewind"
        "patroni ${node.host} postgres"
      ]) nodes;
    };
  };

  configFile = pkgs.writeText "patroni.json" (builtins.toJSON defaultSettings);
in {
  options.clement.patroni = {
    enable = mkEnableOption "Patroni PostgreSQL cluster";

    nodes = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          host = mkOption {
            type = types.str;
            description = "DNS name of the cluster member.";
          };

          address = mkOption {
            type = types.str;
            description = "Network address of the cluster member.";
          };
        };
      });
      description = "Patroni cluster members.";
    };

    clientNetworks = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Networks allowed to connect as the PostgreSQL administrator.";
    };

    tls = {
      etcd = {
        caFile = mkOption {
          type = types.path;
          description = "CA used to authenticate the etcd servers.";
        };

        certFile = mkOption {
          type = types.path;
          description = "Patroni client certificate for etcd.";
        };

        keyFile = mkOption {
          type = types.path;
          description = "Patroni client private key for etcd.";
        };
      };

      postgresql = {
        caFile = mkOption {
          type = types.path;
          description = "CA used for PostgreSQL client and server authentication.";
        };

        certFile = mkOption {
          type = types.path;
          description = "PostgreSQL server certificate.";
        };

        keyFile = mkOption {
          type = types.path;
          description = "PostgreSQL server private key.";
        };

        clientCertFile = mkOption {
          type = types.path;
          description = "PostgreSQL client certificate used by Patroni.";
        };

        clientKeyFile = mkOption {
          type = types.path;
          description = "PostgreSQL client private key used by Patroni.";
        };
      };

      restApi = {
        caFile = mkOption {
          type = types.path;
          description = "CA used for Patroni REST API client and server authentication.";
        };

        certFile = mkOption {
          type = types.path;
          description = "Patroni REST API server and client certificate.";
        };

        keyFile = mkOption {
          type = types.path;
          description = "Patroni REST API server and client private key.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = hasAttr config.networking.hostName cfg.nodes;
      message = "clement.patroni: hostname '${config.networking.hostName}' is not present in the nodes registry";
    }];

    systemd.services.patroni = {
      description = "Patroni PostgreSQL high-availability member";
      after = [ "network-online.target" "etcd.service" ];
      wants = [ "network-online.target" "etcd.service" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.RequiresMountsFor = "/var/lib/private/postgresql";

      protect.enable = true;

      serviceConfig = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = "${pkgs.patroni}/bin/patroni ${configFile}";
        KillMode = "process";
        DynamicUser = true;
        StateDirectory = "postgresql";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "postgresql";
        RuntimeDirectoryMode = "0750";
        UMask = "0077";
        LoadCredential = [
          "etcd-ca.pem:${cfg.tls.etcd.caFile}"
          "etcd-cert.pem:${cfg.tls.etcd.certFile}"
          "etcd-key.pem:${cfg.tls.etcd.keyFile}"
          "postgresql-ca.pem:${cfg.tls.postgresql.caFile}"
          "postgresql-server-cert.pem:${cfg.tls.postgresql.certFile}"
          "postgresql-server-key.pem:${cfg.tls.postgresql.keyFile}"
          "postgresql-client-cert.pem:${cfg.tls.postgresql.clientCertFile}"
          "postgresql-client-key.pem:${cfg.tls.postgresql.clientKeyFile}"
          "patroni-ca.pem:${cfg.tls.restApi.caFile}"
          "patroni-cert.pem:${cfg.tls.restApi.certFile}"
          "patroni-key.pem:${cfg.tls.restApi.keyFile}"
        ];
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutSec = "30s";
        LimitNOFILE = 40000;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/private 0700 root root -"
    ];

    environment.systemPackages = [
      pkgs.patroni
      pkgs.postgresql_18
    ];
  };
}
