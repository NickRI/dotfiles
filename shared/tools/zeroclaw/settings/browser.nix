{ lib, ... }:
{
  options = {
    browser = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allowed_domains = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Allowed domains for `browser_open` (exact or subdomain match)";
          };
          backend = lib.mkOption {
            type = lib.types.enum [
              "agent_browser"
              "rust_native"
              "computer_use"
              "auto"
            ];
            default = "agent_browser";
            description = "Browser automation backend (`agent_browser`, `rust_native`, `computer_use`, `auto`).";
          };
          computer_use = lib.mkOption {
            type = lib.types.submodule {
              options = {
                allow_remote_endpoint = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Allow remote/public endpoint for computer-use sidecar (default: false)";
                };
                api_key = lib.mkOption {
                  type = lib.types.nullOr (lib.types.str);
                  default = null;
                  description = "Optional bearer token for computer-use sidecar";
                };
                endpoint = lib.mkOption {
                  type = lib.types.str;
                  default = "http://127.0.0.1:8787/v1/actions";
                  description = "Sidecar endpoint for computer-use actions (OS-level mouse/keyboard/screenshot)";
                };
                max_coordinate_x = lib.mkOption {
                  type = lib.types.nullOr (lib.types.int);
                  default = 0;
                  description = "Optional X-axis boundary for coordinate-based actions";
                };
                max_coordinate_y = lib.mkOption {
                  type = lib.types.nullOr (lib.types.int);
                  default = 0;
                  description = "Optional Y-axis boundary for coordinate-based actions";
                };
                timeout_ms = lib.mkOption {
                  type = lib.types.int;
                  default = 15000;
                  description = "Per-action request timeout in milliseconds";
                };
                window_allowlist = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "Optional window title/process allowlist forwarded to sidecar policy";
                };
              };
            };
            default = {
              allow_remote_endpoint = false;
              endpoint = "http://127.0.0.1:8787/v1/actions";
              timeout_ms = 15000;
              window_allowlist = [ ];
            };
            description = "Computer-use sidecar configuration (`[browser.computer_use]` section).\n\nDelegates OS-level mouse, keyboard, and screenshot actions to a local sidecar.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable `browser_open` tool (opens URLs in the system browser without scraping)";
          };
          native_chrome_path = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional Chrome/Chromium executable path for rust-native backend";
          };
          native_headless = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Headless mode for rust-native backend";
          };
          native_webdriver_url = lib.mkOption {
            type = lib.types.str;
            default = "http://127.0.0.1:9515";
            description = "WebDriver endpoint URL for rust-native backend (e.g. http://127.0.0.1:9515)";
          };
          session_name = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Browser session name (for agent-browser automation)";
          };
        };
      };
      default = {
        allowed_domains = [ ];
        backend = "agent_browser";
        computer_use = {
          allow_remote_endpoint = false;
          endpoint = "http://127.0.0.1:8787/v1/actions";
          timeout_ms = 15000;
          window_allowlist = [ ];
        };
        enabled = false;
        native_headless = true;
        native_webdriver_url = "http://127.0.0.1:9515";
      };
      description = "Browser automation configuration (`[browser]` section).\n\nControls the `browser_open` tool and browser automation backends.";
    };
  };
}
