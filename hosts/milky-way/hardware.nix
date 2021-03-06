# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/dad2c6fa-5eba-4da6-95a6-3a78d8d71a38";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F84E-D6AB";
      fsType = "vfat";
    };

  fileSystems."/media/backup" =
    { device = "/dev/disk/by-uuid/50353c11-beed-4c9c-8432-bbf608e989e4";
      fsType = "ext4";
    };

  fileSystems."/media/Media" =
    { device = "/dev/disk/by-uuid/30DC85B7DC85783C";
      fsType = "ntfs";
      options = [ "rw" "uid=1000" ];
    };

  fileSystems."/media/TV" =
    { device = "/dev/disk/by-uuid/9C08911F0890FA0A";
      fsType = "ntfs";
      options = [ "rw" "uid=1000" ];
    };

  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
