{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_scsi" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "noatime" "mode=755" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-id/scsi-3601cbf9297b64a96842e1dbd072105fb-part1";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-id/scsi-3601cbf9297b64a96842e1dbd072105fb-part2";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
      neededForBoot = true;
    };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}