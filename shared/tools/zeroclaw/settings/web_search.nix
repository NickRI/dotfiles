{ lib, ... }:
{
  options = {
    web_search = lib.mkOption {
      type = lib.types.submodule {
        options = {
          brave_api_key = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Brave Search API key (required if provider is \"brave\")";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable `web_search_tool` for web searches";
          };
          max_results = lib.mkOption {
            type = lib.types.int;
            default = 5;
            description = "Maximum results per search (1-10)";
          };
          provider = lib.mkOption {
            type = lib.types.str;
            default = "duckduckgo";
            description = "Search provider: \"duckduckgo\" (free, no API key) or \"brave\" (requires API key)";
          };
          timeout_secs = lib.mkOption {
            type = lib.types.int;
            default = 15;
            description = "Request timeout in seconds";
          };
        };
      };
      default = {
        enabled = false;
        max_results = 5;
        provider = "duckduckgo";
        timeout_secs = 15;
      };
      description = "Web search tool configuration (`[web_search]` section).";
    };
  };
}
