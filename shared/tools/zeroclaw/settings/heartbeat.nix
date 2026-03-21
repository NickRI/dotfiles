{ lib, ... }:
{
  options = {
    heartbeat = lib.mkOption {
      type = lib.types.submodule {
        options = {
          adaptive = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable adaptive intervals that back off on failures and speed up for\nhigh-priority tasks. Default: `false`.";
          };
          deadman_channel = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Channel for dead-man's switch alerts (e.g. `telegram`). Falls back to\nthe heartbeat delivery channel.";
          };
          deadman_timeout_minutes = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "Dead-man's switch timeout in minutes. If the heartbeat has not ticked\nwithin this window, an alert is sent. `0` disables. Default: `0`.";
          };
          deadman_to = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Recipient for dead-man's switch alerts. Falls back to `to`.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable periodic heartbeat pings. Default: `false`.";
          };
          interval_minutes = lib.mkOption {
            type = lib.types.int;
            default = 5;
            description = "Interval in minutes between heartbeat pings. Default: `5`.";
          };
          max_interval_minutes = lib.mkOption {
            type = lib.types.int;
            default = 120;
            description = "Maximum interval in minutes when adaptive mode backs off. Default: `120`.";
          };
          max_run_history = lib.mkOption {
            type = lib.types.int;
            default = 100;
            description = "Maximum number of heartbeat run history records to retain. Default: `100`.";
          };
          message = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional fallback task text when `HEARTBEAT.md` has no task entries.";
          };
          min_interval_minutes = lib.mkOption {
            type = lib.types.int;
            default = 5;
            description = "Minimum interval in minutes when adaptive mode is enabled. Default: `5`.";
          };
          target = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional delivery channel for heartbeat output (for example: `telegram`).\nWhen omitted, auto-selects the first configured channel.";
          };
          to = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional delivery recipient/chat identifier (required when `target` is\nexplicitly set).";
          };
          two_phase = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable two-phase heartbeat: Phase 1 asks LLM whether to run, Phase 2\nexecutes only when the LLM decides there is work to do. Saves API cost\nduring quiet periods. Default: `true`.";
          };
        };
      };
      default = {
        adaptive = false;
        deadman_timeout_minutes = 0;
        enabled = false;
        interval_minutes = 5;
        max_interval_minutes = 120;
        max_run_history = 100;
        min_interval_minutes = 5;
        two_phase = true;
      };
      description = "Heartbeat configuration for periodic health pings (`[heartbeat]` section).";
    };
  };
}
