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
    };
  };


#  fileSystems."/" =
#    { device = "/dev/disk/by-uuid/cc468b23-5e57-4006-ae4b-25bec0fccfca";
#      fsType = "ext4";
#      options = [ "noatime" ];
#    };
#
#  fileSystems."/boot" =
#    { device = "/dev/disk/by-uuid/558C-E1E4";
#      fsType = "vfat";
#    };
#
#  swapDevices =
#    [ { device = "/dev/disk/by-uuid/7016fe1f-f046-4221-a404-10ffee6615e0"; }
#    ];
}