{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "noatime" "mode=755" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_43421473-part1";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_43421473-part2";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
      neededForBoot = true;
    };

  fileSystems."/nix/persist" =
    { device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_43421473-part2";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" ];
      neededForBoot = true;
    };

  fileSystems."/var/lib/postgresql" =
    { device = "/dev/disk/by-id/scsi-0HC_Volume_100397238-part1";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
