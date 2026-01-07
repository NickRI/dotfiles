{
  pkgs,
  modulesPath,
  nixos-hardware,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.framework-13th-gen-intel
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  boot.kernelParams = [
    "usbcore.autosuspend=-1"
    "i915.enable_psr=0"
  ];

  hardware.cpu.intel.updateMicrocode = true;
}
