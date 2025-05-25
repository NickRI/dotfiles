{
  pkgs,
  modulesPath,
  nixos-hardware,
  ...
}:
let
  pinnedKernel = pkgs.linuxPackagesFor (
    pkgs.linux_6_14.override {
      argsOverride = rec {
        version = "6.14.6";
        modDirVersion = version;
        src = pkgs.fetchurl {
          url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
          sha256 = "sha256-IYF/GZjiIw+B9+T2Bfpv3LBA4U+ifZnCfdsWznSXl6k=";
        };
      };
    }
  );
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
  ];

  boot.kernelPackages = pinnedKernel; # TODO: Check newer versions of kernels for hibernation
}
