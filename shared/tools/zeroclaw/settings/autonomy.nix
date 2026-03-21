{ lib, ... }:
{
  options = {
    autonomy = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allowed_commands = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Allowlist of executable names permitted for shell execution.";
          };
          allowed_roots = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Extra directory roots the agent may read/write outside the workspace.\nSupports absolute, `~/...`, and workspace-relative entries.\nResolved paths under any of these roots pass `is_resolved_path_allowed`.";
          };
          always_ask = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Tools that always require interactive approval, even after \"Always\".";
          };
          auto_approve = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Tools that never require approval (e.g. read-only tools).";
          };
          block_high_risk_commands = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Block high-risk shell commands even if allowlisted.";
          };
          forbidden_paths = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Explicit path denylist. Default includes system-critical paths and sensitive dotdirs.";
          };
          level = lib.mkOption {
            type = lib.types.enum [
              "supervised"
              "read_only"
              "full"
            ];
            default = "supervised";
            description = "How much autonomy the agent has";
          };
          max_actions_per_hour = lib.mkOption {
            type = lib.types.int;
            default = 20;
            description = "Maximum actions allowed per hour per policy. Default: `100`.";
          };
          max_cost_per_day_cents = lib.mkOption {
            type = lib.types.int;
            default = 500;
            description = "Maximum cost per day in cents per policy. Default: `1000`.";
          };
          non_cli_excluded_tools = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Tools to exclude from non-CLI channels (e.g. Telegram, Discord).\n\nWhen a tool is listed here, non-CLI channels will not expose it to the\nmodel in tool specs.";
          };
          require_approval_for_medium_risk = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Require explicit approval for medium-risk shell commands.";
          };
          shell_env_passthrough = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Additional environment variables allowed for shell tool subprocesses.\n\nThese names are explicitly allowlisted and merged with the built-in safe\nbaseline (`PATH`, `HOME`, etc.) after `env_clear()`.";
          };
          workspace_only = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Restrict absolute filesystem paths to workspace-relative references. Default: `true`.\nResolved paths outside the workspace still require `allowed_roots`.";
          };
        };
      };
      default = {
        allowed_commands = [ ];
        allowed_roots = [ ];
        always_ask = [ ];
        auto_approve = [ ];
        block_high_risk_commands = true;
        forbidden_paths = [ ];
        level = "supervised";
        max_actions_per_hour = 20;
        max_cost_per_day_cents = 500;
        non_cli_excluded_tools = [ ];
        require_approval_for_medium_risk = true;
        shell_env_passthrough = [ ];
        workspace_only = true;
      };
      description = "Autonomy and security policy configuration (`[autonomy]` section).\n\nControls what the agent is allowed to do: shell commands, filesystem access,\nrisk approval gates, and per-policy budgets.";
    };
  };
}
