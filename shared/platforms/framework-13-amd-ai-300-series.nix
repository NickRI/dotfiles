{ modulesPath, nixos-hardware, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];

  boot.blacklistedKernelModules = [ "thunderbolt" ];
}
