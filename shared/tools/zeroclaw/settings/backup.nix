{ lib, ... }:
{
  options = {
    backup = lib.mkOption {
      type = lib.types.submodule {
        options = {
          compress = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Compress backup archives.";
          };
          destination_dir = lib.mkOption {
            type = lib.types.str;
            default = "state/backups";
            description = "Output directory for backup archives (relative to workspace root).";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable the `backup` tool.";
          };
          encrypt = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Encrypt backup archives (requires a configured secret store key).";
          };
          include_dirs = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Workspace subdirectories to include in backups.";
          };
          max_keep = lib.mkOption {
            type = lib.types.int;
            default = 10;
            description = "Maximum number of backups to keep (oldest are pruned).";
          };
          schedule_cron = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional cron expression for scheduled automatic backups.";
          };
          schedule_timezone = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "IANA timezone for `schedule_cron`.";
          };
        };
      };
      default = {
        compress = true;
        destination_dir = "state/backups";
        enabled = true;
        encrypt = false;
        include_dirs = [ ];
        max_keep = 10;
      };
      description = "Backup tool configuration (`[backup]` section).";
    };
  };
}
