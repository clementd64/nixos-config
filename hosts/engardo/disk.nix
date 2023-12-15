{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_40408249";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          main = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        nix = {
          size = "20G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            mountOptions = [
              "defaults"
              "noatime"
            ];
          };
        };
        persist = {
          size = "5G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix/persist";
            mountOptions = [
              "defaults"
            ];
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