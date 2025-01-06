{ config, disko, lib, ... }:

{
#  disko.devices = {
#    disk = {
#      sda = {
#        device = lib.mkDefault "/dev/sda";
#        type = "disk";
#        content = {
#          type = "gpt";
#          partitions = {
#            ESP = {
#              type = "EF00";
#              size = "550M";
#              content = {
#                type = "filesystem";
#                format = "vfat";
#                mountpoint = "/boot";
#              };
#            };
#            root = {
#              size = "100%";
#              content = {
#                type = "filesystem";
#                format = "ext4";
#                mountpoint = "/";
#              };
#            };
#          };
#        };
#      };
#    };
#  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/cc468b23-5e57-4006-ae4b-25bec0fccfca";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/558C-E1E4";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/7016fe1f-f046-4221-a404-10ffee6615e0"; }
    ];
}