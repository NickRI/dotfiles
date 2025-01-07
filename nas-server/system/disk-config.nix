{ config, disko, lib, ... }:

{

  disko.devices = {
    disk = {
      mmcblk0 = {
        device = "/dev/mmcblk0";
        type = "disk";
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
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            primary = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
      two = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            primary = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };

    ##### LVM FOR RAID
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          storage = {
            size = "100%";
            lvm_type = "raid1";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/storage";
              mountOptions = [
                "defaults" "nofail"
              ];
            };
          };
        };
      };
    };

  };
}