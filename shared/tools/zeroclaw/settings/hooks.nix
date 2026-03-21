{ lib, ... }:
{
  options = {
    hooks = lib.mkOption {
      type = lib.types.submodule {
        options = {
          builtin = lib.mkOption {
            type = lib.types.submodule {
              options = {
                command_logger = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable the command-logger hook (logs tool calls for auditing).";
                };
                webhook_audit = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      enabled = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Enable the webhook-audit hook. Default: `false`.";
                      };
                      include_args = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Include tool call arguments in the audit payload. Default: `false`.\n\nBe mindful of sensitive data \u2014 arguments may contain secrets or PII.";
                      };
                      max_args_bytes = lib.mkOption {
                        type = lib.types.int;
                        default = 4096;
                        description = "Maximum size (in bytes) of serialised arguments included in a single\naudit payload. Arguments exceeding this limit are truncated.\nDefault: `4096`.";
                      };
                      tool_patterns = lib.mkOption {
                        type = (lib.types.listOf (lib.types.str));
                        default = [ ];
                        description = "Glob patterns for tool names to audit (e.g. `[\"Bash\", \"Write\"]`).\nAn empty list means **no** tools are audited.";
                      };
                      url = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        description = "Target URL that will receive the audit POST requests.";
                      };
                    };
                  };
                  default = {
                    enabled = false;
                    include_args = false;
                    max_args_bytes = 4096;
                    tool_patterns = [ ];
                    url = "";
                  };
                  description = "Configuration for the webhook-audit builtin hook.\n\nSends an HTTP POST with a JSON body to an external endpoint each time\na tool call matches one of the configured patterns. Useful for\ncentralised audit logging, SIEM ingestion, or compliance pipelines.";
                };
              };
            };
            default = {
              command_logger = false;
              webhook_audit = {
                enabled = false;
                include_args = false;
                max_args_bytes = 4096;
                tool_patterns = [ ];
                url = "";
              };
            };
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable lifecycle hook execution.\n\nHooks run in-process with the same privileges as the main runtime.\nKeep enabled hook handlers narrowly scoped and auditable.";
          };
        };
      };
      default = {
        builtin = {
          command_logger = false;
          webhook_audit = {
            enabled = false;
            include_args = false;
            max_args_bytes = 4096;
            tool_patterns = [ ];
            url = "";
          };
        };
        enabled = true;
      };
    };
  };
}
