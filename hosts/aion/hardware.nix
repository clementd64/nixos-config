{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "virtio_scsi" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "noatime" "mode=755" ];
    };

  fileSystems."/boot" =
    { device = "/dev/vda1";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "/dev/vda2";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
      neededForBoot = true;
    };

  fileSystems."/var/lib/private/etcd" =
    { device = "/dev/vda2";
      fsType = "btrfs";
      options = [ "subvol=etcd" "noatime" "compress=zstd" ];
    };

  fileSystems."/var/lib/private/postgresql" =
    { device = "/dev/sda1";
      fsType = "ext4";
      options = [ "noatime" "noexec" ];
    };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
