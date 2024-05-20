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
      server = "https://10.0.0.200:6443";
      token-file = "/run/secrets/k3s-server-token";
      tls-san = [ "10.0.0.200" ];
    };
    manifests.kube-vip = ./kube-vip.yaml;
  };
  environment.systemPackages = [ pkgs.k3s ];

  clement.secrets."k3s-server-token" = {
    identity = "/nix/persist/age-key";
    text = ''
    -----BEGIN AGE ENCRYPTED FILE-----
    YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSB5cW05L0JRV1ZKWHlYczRR
    K21nV2pIM1k3Y2lYcnl0bUFxTngxaHk4NDI4Cllxa0laUjRacHNib0I5L3NZeEpX
    cVZxTk0vbFpDazJEZzhlT053SW5PVG8KLS0tIC9KcEEyWm1NM1JoTGFjUlF5MGpm
    MmU3MUN6UGRMdUdoSkJaZGdHUkRKSHcKC3eBKvfSay9ngtpIgOs3vDpxfYEa3hEA
    5MtQNBjR/19oUJTMHsqMra9wpqvANweN/gYybnoeZD/dFFKHCAKIzTXxg7v5ZLV5
    HzOySNt0uqojdqQEvgT3SMEQTuOQeDhJEMAUB6RLOjN8x6P7SXCFoYiTXw6a76wJ
    qXMd8fOeqE4peOPtEyR448UJdRiqStwKqN4ZzGX7WS/2AYq2T+psai+tm/28Qei5
    Dztqx1h6EzanWFxBAOxeBTk=
    -----END AGE ENCRYPTED FILE-----
    '';
  };

  # TODO: configure per role
  # TODO: be more restrictive about source IPs (ipset)
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 10.0.0.0/24 -p tcp -m multiport --dports 2379,2380,6443,10250 -j ACCEPT
    iptables -A INPUT -s 10.0.0.0/24 -p udp -m multiport --dports 8472 -j ACCEPT
  '';

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
