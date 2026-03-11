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
    { device = "tmpfs";
      fsType = "tmpfs";
      options = [ "noatime" "mode=755" ];
    };

  fileSystems."/boot" =
    { device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=boot" "noatime" "compress=zstd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
      neededForBoot = true;
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
