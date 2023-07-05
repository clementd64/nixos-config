{ ... }:
{
  virtualisation.docker.enable = true;
  users.users.clement.extraGroups = ["docker"];

  virtualisation.docker.daemon.settings = {
    log-driver = "journald";
    exec-opts = [
      "native.cgroupdriver=systemd"
    ];
    features = {
      buildkit = true;
    };

    default-address-pools = [
      {
        base = "172.17.0.0/16";
        size = 24;
      }
    ];
    bip = "172.17.0.1/24";
  };
}
