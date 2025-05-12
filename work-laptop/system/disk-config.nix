{ ... }:

{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_500GB_22381C805393";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            MBR = {
              type = "EF02";
              size = "1M";
              priority = 1;
            };
            ESP = {
              type = "EF00";
              size = "550M";
              priority = 2;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "34G";
              priority = 3;
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hibernation from this device
              };
            };
            root = {
              size = "280G";
              priority = 4;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            windows = {
              size = "100%";
              priority = 5;
            };
          };
        };
      };
    };
  };
}
