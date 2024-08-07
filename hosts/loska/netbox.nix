{ config, lib, pkgs, ... }:
let
  dataDir = "/var/lib/netbox";

  settingsFile = (pkgs.formats.pythonVars {}).generate "netbox-settings.py" settings;
  extraConfigFile = pkgs.writeTextFile {
    name = "netbox-extra.py";
    text = extraConfig;
  };
  configFile = pkgs.concatText "configuration.py" [ settingsFile extraConfigFile ];

  pkg = (pkgs.netbox_3_7.overrideAttrs (old: {
    installPhase = old.installPhase + ''
      ln -s ${configFile} $out/opt/netbox/netbox/netbox/configuration.py
    '';
  }));

  netboxManageScript = with pkgs; (writeScriptBin "netbox-manage" ''
    #!${stdenv.shell}
    export PYTHONPATH=${pkg.pythonPath}
    sudo -u netbox ${pkg}/bin/netbox "$@"
  '');

  settings = {
    ALLOWED_HOSTS = ["*"];
    CSRF_TRUSTED_ORIGINS = ["http://localhost:8080"];

    STATIC_ROOT = "${dataDir}/static";
    MEDIA_ROOT = "${dataDir}/media";
    REPORTS_ROOT = "${dataDir}/reports";
    SCRIPTS_ROOT = "${dataDir}/scripts";

    DATABASE = {
      NAME = "netbox";
      USER = "netbox";
      HOST = "10.0.0.3";
    };

    REDIS = {
      tasks = {
          URL = "unix://${config.services.redis.servers.netbox.unixSocket}?db=0";
          SSL = false;
      };
      caching =  {
          URL = "unix://${config.services.redis.servers.netbox.unixSocket}?db=1";
          SSL = false;
      };
    };
  };

  extraConfig = ''
    with open("/run/secrets/netbox-database-password", "r") as file:
      DATABASE['PASSWORD'] = file.readline()
    with open("/run/secrets/netbox-secret", "r") as file:
      SECRET_KEY = file.readline()
  '';
in {
  services.redis.servers.netbox.enable = true;
  environment.systemPackages = [ netboxManageScript ];

  systemd.targets.netbox = {
    description = "Target for all NetBox services";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "redis-netbox.service" ];
  };

  systemd.services = let
    defaultServiceConfig = {
      WorkingDirectory = "${dataDir}";
      User = "netbox";
      Group = "netbox";
      StateDirectory = "netbox";
      StateDirectoryMode = "0750";
      Restart = "on-failure";
      RestartSec = 30;
    };
  in {
    netbox = {
      description = "NetBox WSGI Service";
      documentation = [ "https://docs.netbox.dev/" ];

      wantedBy = [ "netbox.target" ];

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment.PYTHONPATH = pkg.pythonPath;

      preStart = ''
        # On the first run, or on upgrade / downgrade, run migrations and related.
        # This mostly correspond to upstream NetBox's 'upgrade.sh' script.
        versionFile="${dataDir}/version"

        if [[ -e "$versionFile" && "$(cat "$versionFile")" == "${pkg.version}" ]]; then
          exit 0
        fi

        ${pkg}/bin/netbox migrate
        ${pkg}/bin/netbox trace_paths --no-input
        ${pkg}/bin/netbox collectstatic --no-input
        ${pkg}/bin/netbox remove_stale_contenttypes --no-input
        ${pkg}/bin/netbox reindex --lazy
        ${pkg}/bin/netbox clearsessions

        echo "${pkg.version}" > "$versionFile"
      '';

      serviceConfig = defaultServiceConfig // {
        ExecStart = ''
          ${pkg.gunicorn}/bin/gunicorn netbox.wsgi \
            --bind [::1]:8001 \
            --pythonpath ${pkg}/opt/netbox/netbox
        '';
        PrivateTmp = true;
      };
    };
  };

  users.users.netbox = {
    home = "${dataDir}";
    isSystemUser = true;
    group = "netbox";
  };
  users.groups.netbox = {};
  users.groups."${config.services.redis.servers.netbox.user}".members = [ "netbox" ];

  clement.secrets."netbox-database-password" = {
    text = ''
      -----BEGIN AGE ENCRYPTED FILE-----
      YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IHNzaC1lZDI1NTE5IFUzaXJvZyBrM3R1
      U0U2cmx1MzFxbXdHeU92d1pRMEdnTWZTV1dtVVo4YkRRYXkvMWxVCjFsTy9Kc2Ey
      U0pSUnIzRHE2bytZdUxoV21SMWpaOVFaZUZCMHJWZHFkYzQKLS0tICsza2FjOTVi
      cm9NZTlpQzlVa281dWxSUHU4amlFVHBlQlpNMFVNaENoeGcKtnXQxoFS0IMuEJP2
      XbPzMqpVVD8f3BnsxAdMvkZ1Nks3oUYVeulpvMhkG6/P0rC91tph8JYdvGrJNHXc
      v+bPGBuAAGvbOaR2
      -----END AGE ENCRYPTED FILE-----
      '';
    user = "netbox";
    group = "netbox";
  };

  clement.secrets."netbox-secret" = {
    text = ''
      -----BEGIN AGE ENCRYPTED FILE-----
      YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IHNzaC1lZDI1NTE5IFUzaXJvZyBwM0xs
      YkhCZnpxdk5DVGdIdXhsWUUrTHJ5OXFLUURZZXlGcG1NcFYrdGdrCkZwZG9WR0RQ
      VGZka3VvaWpyMFZ0bTBMR1Y0UVhQR0p6TmZyVjJUMDFJY2MKLS0tIG1kK0I2VllT
      eGU2Tk0zZnVZSmlHU3N2T1ZFbVFHeGhpTXBlRWFVU3JPdk0KJKLDcGlQzl0gC/qJ
      4he4/ldGWDIYMe9pxxcW8750esqcqOS522jQ0h2Lyhsdv7DejFnuJaH/Go7zz9j3
      Tzelr1GmGw3LA7i6z5xHvmTytStM2Q==
      -----END AGE ENCRYPTED FILE-----
      '';
    user = "netbox";
    group = "netbox";
  };

  services.nginx = {
    enable = true;
    user = "netbox";
    clientMaxBodySize = "25m";

    virtualHosts."netbox" = {
      locations = {
        "/" = {
          proxyPass = "http://[::1]:8001";
        };
        "/static/" = { alias = "${dataDir}/static/"; };
      };
      serverName = "_";
    };
  };
}
