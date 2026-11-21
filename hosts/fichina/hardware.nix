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
    { device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_134101093-part1";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_134101093-part2";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=nix" ];
    };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}