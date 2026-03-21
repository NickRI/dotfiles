{ lib, ... }:
{
  options = {
    http_request = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allow_private_hosts = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow requests to private/LAN hosts (RFC 1918, loopback, link-local, .local).\nDefault: false (deny private hosts for SSRF protection).";
          };
          allowed_domains = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Allowed domains for HTTP requests (exact or subdomain match)";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable `http_request` tool for API interactions";
          };
          max_response_size = lib.mkOption {
            type = lib.types.int;
            default = 1000000;
            description = "Maximum response size in bytes (default: 1MB, 0 = unlimited)";
          };
          timeout_secs = lib.mkOption {
            type = lib.types.int;
            default = 30;
            description = "Request timeout in seconds (default: 30)";
          };
        };
      };
      default = {
        allow_private_hosts = false;
        allowed_domains = [ ];
        enabled = false;
        max_response_size = 1000000;
        timeout_secs = 30;
      };
      description = "HTTP request tool configuration (`[http_request]` section).\n\nDeny-by-default: if `allowed_domains` is empty, all HTTP requests are rejected.";
    };
  };
}
