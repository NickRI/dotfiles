{ ... }:

{

  disko.devices = {
    disk = {
      mmcblk0 = {
        type = "disk";
        device = "/dev/disk/by-id/mmc-C9A551_0xb70840d0";
        content = {
          type = "gpt";
          partitions = {
            MBR = {
              type = "EF02"; # for grub MBR
              size = "1M";
              priority = 1; # Needs to be first partition
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
      #### RAID 1 Disks
      one = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST3000DM007-1WY10G_ZTT2E950";
        content = {
          type = "gpt";
          partitions = {
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "storage";
              };
            };
          };
        };
      };
      two = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST3000DM007-1WY10G_WFN7PQLE";
        content = {
          type = "gpt";
          partitions = {
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "storage";
              };
            };
          };
        };
      };
    };
    ### Software RAID config
    mdadm = {
      storage = {
        type = "mdadm";
        level = 1;
        content = {
          type = "gpt";
          partitions.primary = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/storage";
              mountOptions = [
                "defaults"
                "nofail"
              ];
            };
          };
        };
      };
    };

    #    nodev.nix = {
    #      type = "bind";
    #      source = "/storage/nix";
    #      mountpoint = "/nix";
    #    };
  };
}
