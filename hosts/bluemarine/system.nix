{ lib, pkgs, ... }:
{
  systemd.network = {
    enable = true;
    networks."40-host0" = {
      matchConfig.Name = "host0";
      networkConfig.Address = [ "${pkgs.net.genIPv6Addr "2a0c:b641:2b2::" "bluemarine"}/128" ];
      routes = [
        { Gateway = pkgs.net.genLinkLocal "zoness"; }
      ];
    };
  };

  clement.credentials.postgresql = {
    file = ./secrets.json;
    service = "postgresql";
    secrets = {
      "ca".extract = ''["postgresql"]["ca"]'';
      "cert".extract = ''["postgresql"]["cert"]'';
      "key".extract = ''["postgresql"]["key"]'';
    };
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_18;
    authentication = lib.mkOverride 10 ''
      #type    database  DBuser    address                                                auth-method
      local    all       postgres                                                         peer
      hostssl  sameuser  all       ${pkgs.net.genIPv6Addr "2a0c:b641:2b2::" "falco"}/128  cert
    '';
    settings = {
      ssl = true;
      ssl_ca_file = "/run/credentials/postgresql.service/ca";
      ssl_cert_file = "/run/credentials/postgresql.service/cert";
      ssl_key_file = "/run/credentials/postgresql.service/key";
      ssl_min_protocol_version = "TLSv1.3";
    };
  };

  clement.firewall.src."tcp:5432" = [
    "${pkgs.net.genIPv6Addr "2a0c:b641:2b2::" "falco"}/128"
  ];

  clement.restic = {
    secrets = {
      file = ./secrets.json;
      extract = ''["restic"]'';
    };
    postgresql.databases = {
      codex = {};
      miniflux = {};
      pocketid = {};
      synapse.exclude-table-data = [ "public.e2e_one_time_keys_json" ];
    };
  };

  system.stateVersion = "26.05";
}