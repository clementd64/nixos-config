{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "noatime" "mode=755" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA634507N9480FGN-part2";
      fsType = "btrfs";
      options = [ "subvol=boot" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA634507N9480FGN-part2";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA634507N9480FGN-part2";
      fsType = "btrfs";
      options = [ "subvol=docker" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/lib/postgresql" =
    { device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB480G6_PHWA634507N9480FGN-part2";
      fsType = "btrfs";
      options = [ "subvol=postgresql" "compress=zstd" "noatime" ];
    };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}