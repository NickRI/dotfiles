{ lib, ... }:
{
  options = {
    gateway = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allow_public_bind = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow binding to non-localhost without a tunnel (default: false)";
          };
          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "Gateway host (default: 127.0.0.1)";
          };
          web_dist_dir = lib.mkOption {
            type = lib.types.str;
            default = "web";
          };
          idempotency_max_keys = lib.mkOption {
            type = lib.types.int;
            default = 10000;
            description = "Maximum distinct idempotency keys retained in memory.";
          };
          idempotency_ttl_secs = lib.mkOption {
            type = lib.types.int;
            default = 300;
            description = "TTL for webhook idempotency keys.";
          };
          pair_rate_limit_per_minute = lib.mkOption {
            type = lib.types.int;
            default = 10;
            description = "Max `/pair` requests per minute per client key.";
          };
          paired_tokens = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Paired bearer tokens (managed automatically, not user-edited)";
          };
          pairing_dashboard = lib.mkOption {
            type = lib.types.submodule {
              options = {
                code_length = lib.mkOption {
                  type = lib.types.int;
                  default = 8;
                  description = "Length of pairing codes (default: 8)";
                };
                code_ttl_secs = lib.mkOption {
                  type = lib.types.int;
                  default = 3600;
                  description = "Time-to-live for pending pairing codes in seconds (default: 3600)";
                };
                lockout_secs = lib.mkOption {
                  type = lib.types.int;
                  default = 300;
                  description = "Lockout duration in seconds after max attempts (default: 300)";
                };
                max_failed_attempts = lib.mkOption {
                  type = lib.types.int;
                  default = 5;
                  description = "Maximum failed pairing attempts before lockout (default: 5)";
                };
                max_pending_codes = lib.mkOption {
                  type = lib.types.int;
                  default = 3;
                  description = "Maximum concurrent pending pairing codes (default: 3)";
                };
              };
            };
            default = {
              code_length = 8;
              code_ttl_secs = 3600;
              lockout_secs = 300;
              max_failed_attempts = 5;
              max_pending_codes = 3;
            };
            description = "Pairing dashboard configuration (`[gateway.pairing_dashboard]`).";
          };
          port = lib.mkOption {
            type = lib.types.int;
            default = 42617;
            description = "Gateway port (default: 42617)";
          };
          rate_limit_max_keys = lib.mkOption {
            type = lib.types.int;
            default = 10000;
            description = "Maximum distinct client keys tracked by gateway rate limiter maps.";
          };
          require_pairing = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Require pairing before accepting requests (default: true)";
          };
          session_persistence = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Persist gateway WebSocket chat sessions to SQLite. Default: true.";
          };
          session_ttl_hours = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "Auto-archive stale gateway sessions older than N hours. 0 = disabled. Default: 0.";
          };
          trust_forwarded_headers = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Trust proxy-forwarded client IP headers (`X-Forwarded-For`, `X-Real-IP`).\nDisabled by default; enable only behind a trusted reverse proxy.";
          };
          webhook_rate_limit_per_minute = lib.mkOption {
            type = lib.types.int;
            default = 60;
            description = "Max `/webhook` requests per minute per client key.";
          };
        };
      };
      default = {
        allow_public_bind = true;
        host = "127.0.0.1";
        idempotency_max_keys = 10000;
        idempotency_ttl_secs = 300;
        pair_rate_limit_per_minute = 10;
        paired_tokens = [ ];
        pairing_dashboard = {
          code_length = 8;
          code_ttl_secs = 3600;
          lockout_secs = 300;
          max_failed_attempts = 5;
          max_pending_codes = 3;
        };
        port = 42617;
        rate_limit_max_keys = 10000;
        require_pairing = true;
        session_persistence = true;
        session_ttl_hours = 0;
        trust_forwarded_headers = false;
        webhook_rate_limit_per_minute = 60;
      };
      description = "Gateway server configuration (`[gateway]` section).\n\nControls the HTTP gateway for webhook and pairing endpoints.";
    };
  };
}
