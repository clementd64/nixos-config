{ pkgs, lib, ... }:
{
  boot.isContainer = true;
  networking.useHostResolvConf = false;
  networking.useDHCP = false;

  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        Address = [ "2a01:4f8:c17:aad:ff00::1/72" "10.0.0.1/24" ];
        Gateway = [ "2a01:4f8:c17:aad:ff00::ffff" "10.0.0.254" ];
      };
    };

    wait-online.anyInterface = true;
  };

  clement.ssh.enable = true;
  clement.k3s = {
    enable = true;
    role = "server";
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/rancher/k3s"
    ];
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  environment.systemPackages = with pkgs; [
    k3s
  ];

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

  clement.secrets."test".text = ''
    -----BEGIN AGE ENCRYPTED FILE-----
    YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IHNzaC1lZDI1NTE5IG4vVnFaUSB0Mkxx
    SDFBQndwM1FZSHdjZzFGTGZzZU5HcytkZ1V1V1I5d0hiUkVjVUFrCjVUZ095VGpw
    QUhJMHFwU3NMT0ZueFZHSDZudlloRjlqZ2tsTTJaTmt0blEKLS0tIGhGejRLcENZ
    cEh5MXdONUlxOW1JVXhiUW10ZitwdDRQQjhINm9ESXFlaWMKZLgfcqkFxP3uVgHH
    BcCWLYuPPf3JlZSYvZLtomu+IH0Ru/JDSw==
    -----END AGE ENCRYPTED FILE-----
    '';

  system.stateVersion = "23.11";
}
