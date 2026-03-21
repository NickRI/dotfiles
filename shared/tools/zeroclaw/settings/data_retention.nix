{ lib, ... }:
{
  options = {
    data_retention = lib.mkOption {
      type = lib.types.submodule {
        options = {
          categories = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Limit retention enforcement to specific data categories (empty = all).";
          };
          dry_run = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Preview what would be deleted without actually removing anything.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the `data_management` tool.";
          };
          retention_days = lib.mkOption {
            type = lib.types.int;
            default = 90;
            description = "Days of data to retain before purge eligibility.";
          };
        };
      };
      default = {
        categories = [ ];
        dry_run = false;
        enabled = false;
        retention_days = 90;
      };
      description = "Data retention and purge configuration (`[data_retention]` section).";
    };
  };
}
