{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_53265838";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";
          };
          main = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/boot" = {
                  mountpoint = "/boot";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/factorio" = {
                  mountpoint = "/var/lib/factorio";
                  mountOptions = [ "compress=zstd" "noatime" ];
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