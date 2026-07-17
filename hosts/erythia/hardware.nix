{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "tmpfs";
      fsType = "tmpfs";
      options = [ "noatime" "mode=755" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/fa1e6040-bdc4-4cca-9de9-5169e94a1288";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=boot" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/fa1e6040-bdc4-4cca-9de9-5169e94a1288";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
      neededForBoot = true;
    };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}