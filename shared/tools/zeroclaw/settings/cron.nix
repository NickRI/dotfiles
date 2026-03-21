{ lib, ... }:
{
  options = {
    cron = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable the cron subsystem. Default: `true`.";
          };
          max_run_history = lib.mkOption {
            type = lib.types.int;
            default = 50;
            description = "Maximum number of historical cron run records to retain. Default: `50`.";
          };
        };
      };
      default = {
        enabled = true;
        max_run_history = 50;
      };
      description = "Cron job configuration (`[cron]` section).";
    };
  };
}
