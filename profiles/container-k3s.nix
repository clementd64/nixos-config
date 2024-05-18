{ pkgs, ... }:
{
  boot.isContainer = true;
  networking.useHostResolvConf = false;
  networking.useDHCP = false;

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
  };

  clement.ssh.enable = true;
  clement.k3s = {
    enable = true;
    config = {
      server = "https://10.0.0.1:6443";
      token-file = "/run/secrets/k3s-server-token";
    };
  };
  environment.systemPackages = [ pkgs.k3s ];

  clement.secrets."k3s-server-token" = {
    identity = "/nix/persist/age-key";
    text = ''
    -----BEGIN AGE ENCRYPTED FILE-----
    YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBZMXhHTDBjb3ROUTZZeXZp
    bWpQYmVqYlpGVzllMGtwL2lNWWhEc09BNzBBCjdhNjlpUHVTd3ZsWU9OcFVIN3hY
    ekUvZ3lpRWplR2svOUQyYjNlb2xrbG8KLS0tIDNTRm15MVhJTWRWd3FPdHR1YlQ4
    SWlyTWNBZkl1bDIzRU0ySGMvWFN6UXMKkNY+9IX5NUz2aIMgkkCT6qqVM4OF/viE
    dFharsL4tvUqO5q2S2QFAthsXSGxB4SgOX5EtIkKvjwjCiSFE4zNB6bXeRThp0/2
    bxhDW7MthmoTRo/m3kpEzHPkxZM5UF1Q6RcUdkA8K1n+MLJZU00=
    -----END AGE ENCRYPTED FILE-----
    '';
  };

  # TODO: set only for server
  networking.firewall.allowedTCPPorts = [ 6443 ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/rancher/k3s"
    ];
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:clementd64/nixos-config";
    dates = "02:00";
    randomizedDelaySec = "30min";
  };
  systemd.services.nixos-upgrade.environment.NIX_REMOTE = "daemon";
  environment.sessionVariables.NIX_REMOTE = "daemon";

  # Required for kubelet. Can't use tmpfiles because /dev is ignored.
  boot.postBootCommands = "ln -s /dev/null /dev/kmsg";

  system.stateVersion = "23.11";
}
