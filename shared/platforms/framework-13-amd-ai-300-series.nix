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
    pkgs.llama-cpp-rocm
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_7_1;
}
