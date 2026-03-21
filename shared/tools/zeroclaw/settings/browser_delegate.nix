{ lib, ... }:
{
  options = {
    browser_delegate = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allowed_domains = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Allowed domains for browser navigation (empty = allow all non-blocked).";
          };
          blocked_domains = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Blocked domains for browser navigation.";
          };
          chrome_profile_dir = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Chrome profile directory for persistent SSO sessions.";
          };
          cli_binary = lib.mkOption {
            type = lib.types.str;
            default = "claude";
            description = "CLI binary to use for browser tasks (default: `\"claude\"`).";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable browser delegation tool.";
          };
          task_timeout_secs = lib.mkOption {
            type = lib.types.int;
            default = 120;
            description = "Task timeout in seconds.";
          };
        };
      };
      default = {
        allowed_domains = [ ];
        blocked_domains = [ ];
        chrome_profile_dir = "";
        cli_binary = "claude";
        enabled = false;
        task_timeout_secs = 120;
      };
      description = "Configuration for browser delegation (`[browser_delegate]` section).";
    };
  };
}
