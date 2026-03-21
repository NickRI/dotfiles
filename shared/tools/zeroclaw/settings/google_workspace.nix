{ lib, ... }:
{
  options = {
    google_workspace = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allowed_services = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Restrict which Google Workspace services the agent can access.\n\nWhen empty (the default), the full default service set is allowed (see\nstruct-level docs). When non-empty, only the listed service IDs are\npermitted. Each entry must be non-empty, lowercase alphanumeric with\noptional underscores/hyphens, and unique.";
          };
          audit_log = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable audit logging of every `gws` invocation (service, resource,\nmethod, timestamp). Default: `false`.";
          };
          credentials_path = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Path to service account JSON or OAuth client credentials file.\n\nWhen `None`, the tool relies on the default `gws` credential discovery\n(`gws auth login`). Set this to point at a service-account key or an\nOAuth client-secrets JSON for headless / CI environments.";
          };
          default_account = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Default Google account email to pass to `gws --account`.\n\nWhen `None`, the currently active `gws` account is used.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the `google_workspace` tool. Default: `false`.";
          };
          rate_limit_per_minute = lib.mkOption {
            type = lib.types.int;
            default = 60;
            description = "Maximum number of `gws` API calls allowed per minute. Default: `60`.";
          };
          timeout_secs = lib.mkOption {
            type = lib.types.int;
            default = 30;
            description = "Command execution timeout in seconds. Default: `30`.";
          };
        };
      };
      default = {
        allowed_services = [ ];
        audit_log = false;
        enabled = false;
        rate_limit_per_minute = 60;
        timeout_secs = 30;
      };
      description = "Google Workspace CLI (`gws`) tool configuration (`[google_workspace]` section).\n\n## Defaults\n- `enabled`: `false` (tool is not registered unless explicitly opted-in).\n- `allowed_services`: empty vector, which grants access to the full default\n  service set: `drive`, `sheets`, `gmail`, `calendar`, `docs`, `slides`,\n  `tasks`, `people`, `chat`, `classroom`, `forms`, `keep`, `meet`, `events`.\n- `credentials_path`: `None` (uses default `gws` credential discovery).\n- `default_account`: `None` (uses the `gws` active account).\n- `rate_limit_per_minute`: `60`.\n- `timeout_secs`: `30`.\n- `audit_log`: `false`.\n- `credentials_path`: `None` (uses default `gws` credential discovery).\n- `default_account`: `None` (uses the `gws` active account).\n- `rate_limit_per_minute`: `60`.\n- `timeout_secs`: `30`.\n- `audit_log`: `false`.\n\n## Compatibility\nConfigs that omit the `[google_workspace]` section entirely are treated as\n`GoogleWorkspaceConfig::default()` (disabled, all defaults allowed). Adding\nthe section is purely opt-in and does not affect other config sections.\n\n## Rollback / Migration\nTo revert, remove the `[google_workspace]` section from the config file (or\nset `enabled = false`). No data migration is required; the tool simply stops\nbeing registered.";
    };
  };
}
