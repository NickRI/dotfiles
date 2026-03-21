{ lib, ... }:
{
  options = {
    web_fetch = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allowed_domains = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Allowed domains for web fetch (exact or subdomain match; `[\"*\"]` = all public hosts)";
          };
          blocked_domains = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Blocked domains (exact or subdomain match; always takes priority over allowed_domains)";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable `web_fetch` tool for fetching web page content";
          };
          max_response_size = lib.mkOption {
            type = lib.types.int;
            default = 500000;
            description = "Maximum response size in bytes (default: 500KB, plain text is much smaller than raw HTML)";
          };
          timeout_secs = lib.mkOption {
            type = lib.types.int;
            default = 30;
            description = "Request timeout in seconds (default: 30)";
          };
        };
      };
      default = {
        allowed_domains = [ "*" ];
        blocked_domains = [ ];
        enabled = false;
        max_response_size = 500000;
        timeout_secs = 30;
      };
      description = "Web fetch tool configuration (`[web_fetch]` section).\n\nFetches web pages and converts HTML to plain text for LLM consumption.\nDomain filtering: `allowed_domains` controls which hosts are reachable (use `[\"*\"]`\nfor all public hosts). `blocked_domains` takes priority over `allowed_domains`.\nIf `allowed_domains` is empty, all requests are rejected (deny-by-default).";
    };
  };
}
