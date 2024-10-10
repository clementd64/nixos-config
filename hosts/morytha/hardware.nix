{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "noatime" "mode=755" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_53265838-part2";
      fsType = "btrfs";
      options = [ "subvol=boot" "noatime" "compress=zstd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_53265838-part2";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
    };

  fileSystems."/var/lib/factorio" =
    { device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_53265838-part2";
      fsType = "btrfs";
      options = [ "subvol=factorio" "noatime" "compress=zstd" ];
    };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}