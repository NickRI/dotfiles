{ lib, ... }:
{
  options = {
    security = lib.mkOption {
      type = lib.types.submodule {
        options = {
          audit = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Enable audit logging";
                };
                log_path = lib.mkOption {
                  type = lib.types.str;
                  default = "audit.log";
                  description = "Path to audit log file (relative to zeroclaw dir)";
                };
                max_size_mb = lib.mkOption {
                  type = lib.types.int;
                  default = 100;
                  description = "Maximum log size in MB before rotation";
                };
                sign_events = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Sign events with HMAC for tamper evidence";
                };
              };
            };
            default = {
              enabled = true;
              log_path = "audit.log";
              max_size_mb = 100;
              sign_events = false;
            };
            description = "Audit logging configuration";
          };
          estop = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable emergency stop controls.";
                };
                require_otp_to_resume = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Require a valid OTP before resume operations.";
                };
                state_file = lib.mkOption {
                  type = lib.types.str;
                  default = "~/.zeroclaw/estop-state.json";
                  description = "File path used to persist estop state.";
                };
              };
            };
            default = {
              enabled = false;
              require_otp_to_resume = true;
              state_file = "~/.zeroclaw/estop-state.json";
            };
            description = "Emergency stop configuration.";
          };
          nevis = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable Nevis IAM integration.";
                };
                instance_url = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Base URL of the Nevis instance (e.g. `https://nevis.example.com`).";
                };
                realm = lib.mkOption {
                  type = lib.types.str;
                  default = "master";
                  description = "Nevis realm to authenticate against.";
                };
                client_id = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "OAuth2 client ID registered in Nevis.";
                };
                client_secret = lib.mkOption {
                  type = lib.types.nullOr (lib.types.str);
                  default = null;
                  description = "OAuth2 client secret (stored encrypted on disk when set).";
                };
                token_validation = lib.mkOption {
                  type = lib.types.enum [
                    "local"
                    "remote"
                  ];
                  default = "local";
                  description = "Token validation strategy: `\"local\"` (JWKS) or `\"remote\"` (introspection).";
                };
                jwks_url = lib.mkOption {
                  type = lib.types.nullOr (lib.types.str);
                  default = null;
                  description = "JWKS endpoint URL for local token validation.";
                };
                role_mapping = lib.mkOption {
                  type = (
                    lib.types.listOf (
                      lib.types.submodule {
                        options = {
                          nevis_role = lib.mkOption {
                            type = lib.types.str;
                            description = "Nevis role name (case-insensitive).";
                          };
                          zeroclaw_permissions = lib.mkOption {
                            type = (lib.types.listOf (lib.types.str));
                            default = [ ];
                            description = "Tool names this role can access; use `\"all\"` for unrestricted tool access.";
                          };
                          workspace_access = lib.mkOption {
                            type = (lib.types.listOf (lib.types.str));
                            default = [ ];
                            description = "Workspace names this role can access; use `\"all\"` for unrestricted.";
                          };
                        };
                      }
                    )
                  );
                  default = [ ];
                  description = "Nevis role to ZeroClaw permission mappings.";
                };
                require_mfa = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Require MFA verification for all Nevis-authenticated requests.";
                };
                session_timeout_secs = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  default = 3600;
                  description = "Session timeout in seconds.";
                };
              };
            };
            default = {
              client_id = "";
              enabled = false;
              instance_url = "";
              realm = "master";
              require_mfa = false;
              role_mapping = [ ];
              session_timeout_secs = 3600;
              token_validation = "local";
            };
            description = "Nevis IAM integration configuration.\n\nWhen `enabled` is true, ZeroClaw validates incoming requests against a Nevis\nSecurity Suite instance and maps Nevis roles to tool/workspace permissions.";
          };
          otp = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable OTP gating.";
                };
                method = lib.mkOption {
                  type = lib.types.enum [
                    "totp"
                    "pairing"
                    "cli-prompt"
                  ];
                  default = "totp";
                  description = "OTP validation strategy (`totp`, `pairing`, `cli-prompt`).";
                };
                token_ttl_secs = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  default = 30;
                  description = "TOTP time-step in seconds.";
                };
                cache_valid_secs = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  default = 300;
                  description = "Reuse window for recently validated OTP codes.";
                };
                gated_actions = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [
                    "shell"
                    "file_write"
                    "browser_open"
                    "browser"
                    "memory_forget"
                  ];
                  description = "Tool/action names gated by OTP.";
                };
                gated_domains = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "Explicit domain patterns gated by OTP.";
                };
                gated_domain_categories = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "Domain-category presets expanded into `gated_domains`.";
                };
                challenge_max_attempts = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  default = 3;
                  description = "Maximum OTP challenge attempts before lockout.";
                };
              };
            };
            default = {
              cache_valid_secs = 300;
              challenge_max_attempts = 3;
              enabled = false;
              gated_actions = [
                "shell"
                "file_write"
                "browser_open"
                "browser"
                "memory_forget"
              ];
              gated_domain_categories = [ ];
              gated_domains = [ ];
              method = "totp";
              token_ttl_secs = 30;
            };
            description = "Security OTP configuration.";
          };
          resources = lib.mkOption {
            type = lib.types.submodule {
              options = {
                max_cpu_time_seconds = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  default = 60;
                  description = "Maximum CPU time in seconds per command";
                };
                max_memory_mb = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  default = 512;
                  description = "Maximum memory in MB per command";
                };
                max_subprocesses = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  default = 10;
                  description = "Maximum number of subprocesses";
                };
                memory_monitoring = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Enable memory monitoring";
                };
              };
            };
            default = {
              max_cpu_time_seconds = 60;
              max_memory_mb = 512;
              max_subprocesses = 10;
              memory_monitoring = true;
            };
            description = "Resource limits for command execution";
          };
          sandbox = lib.mkOption {
            type = lib.types.submodule {
              options = {
                backend = lib.mkOption {
                  type = lib.types.enum [
                    "auto"
                    "landlock"
                    "firejail"
                    "bubblewrap"
                    "docker"
                    "none"
                  ];
                  default = "auto";
                  description = "Sandbox backend (`auto`, `landlock`, `firejail`, `bubblewrap`, `docker`, `none`).";
                };
                enabled = lib.mkOption {
                  type = lib.types.nullOr (lib.types.bool);
                  default = null;
                  description = "Enable sandboxing (`null` = auto-detect, `true`/`false` = explicit).";
                };
                firejail_args = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "Custom Firejail arguments (when backend = firejail)";
                };
              };
            };
            default = {
              backend = "auto";
              firejail_args = [ ];
            };
            description = "Sandbox configuration for OS-level isolation";
          };
        };
      };
      default = {
        audit = {
          enabled = true;
          log_path = "audit.log";
          max_size_mb = 100;
          sign_events = false;
        };
        estop = {
          enabled = false;
          require_otp_to_resume = true;
          state_file = "~/.zeroclaw/estop-state.json";
        };
        nevis = {
          client_id = "";
          enabled = false;
          instance_url = "";
          realm = "master";
          require_mfa = false;
          role_mapping = [ ];
          session_timeout_secs = 3600;
          token_validation = "local";
        };
        otp = {
          cache_valid_secs = 300;
          challenge_max_attempts = 3;
          enabled = false;
          gated_actions = [
            "shell"
            "file_write"
            "browser_open"
            "browser"
            "memory_forget"
          ];
          gated_domain_categories = [ ];
          gated_domains = [ ];
          method = "totp";
          token_ttl_secs = 30;
        };
        resources = {
          max_cpu_time_seconds = 60;
          max_memory_mb = 512;
          max_subprocesses = 10;
          memory_monitoring = true;
        };
        sandbox = {
          backend = "auto";
          firejail_args = [ ];
        };
      };
      description = "Security configuration for sandboxing, resource limits, and audit logging";
    };
  };
}
