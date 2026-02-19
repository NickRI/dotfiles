{
  pkgs,
  lib,
  modulesPath,
  nixos-hardware,
  ...
}:
let
  debug-tools = import ../tools/debug-tools/amd.nix {
    inherit pkgs;
    inherit lib;
  };
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  environment.systemPackages = [
    debug-tools
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];

  programs.ryzen-monitor-ng.enable = true;
  hardware.cpu.amd.ryzen-smu.enable = true;

  boot.kernelParams = [
    "pcie_aspm=force"
    "amd_iommu=fullflush"
    "xhci_hcd.quirks=0x800000"
    "amdgpu.dcdebugmask=0x10"
  ];
}
