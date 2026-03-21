{ lib, ... }:
{
  options = {
    scheduler = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable the built-in scheduler loop.";
          };
          max_concurrent = lib.mkOption {
            type = lib.types.int;
            default = 4;
            description = "Maximum tasks executed per scheduler polling cycle.";
          };
          max_tasks = lib.mkOption {
            type = lib.types.int;
            default = 64;
            description = "Maximum number of persisted scheduled tasks.";
          };
        };
      };
      default = {
        enabled = true;
        max_concurrent = 4;
        max_tasks = 64;
      };
      description = "Scheduler configuration for periodic task execution (`[scheduler]` section).";
    };
  };
}
