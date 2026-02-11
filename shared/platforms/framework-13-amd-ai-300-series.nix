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

  boot.kernelParams = [
    "pcie_aspm=force"
    "amd_iommu=fullflush"
    "xhci_hcd.quirks=0x800000"
    "amdgpu.dcdebugmask=0x10"
  ];
}
