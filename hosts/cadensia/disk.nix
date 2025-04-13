{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA61620654480FGN";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            main = {
              size = "100%";
            };
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA634507N9480FGN";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            main = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" "-m raid1 -d raid1" "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA61620654480FGN-part2"];
                subvolumes = {
                  "/boot" = {
                    mountpoint = "/boot";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/postgresql" = {
                    mountpoint = "/var/lib/postgresql";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/rabbitmq" = {
                    mountpoint = "/var/lib/rabbitmq";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/k3s" = {
                    mountpoint = "/var/lib/rancher/k3s";
                    mountOptions = [ "compress=zstd" ];
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "noatime"
        "mode=755"
      ];
    };
  };
}