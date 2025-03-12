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
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            windows = {
              size = "160G";
            };
            swap = {
              size = "34G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hibernation from this device
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}

