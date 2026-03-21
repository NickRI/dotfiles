{ lib, ... }:
{
  options = {
    mcp = lib.mkOption {
      type = lib.types.submodule {
        options = {
          deferred_loading = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Load MCP tool schemas on-demand via `tool_search` instead of eagerly\nincluding them in the LLM context window. When `true` (the default),\nonly tool names are listed in the system prompt; the LLM must call\n`tool_search` to fetch full schemas before invoking a deferred tool.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable MCP tool loading.";
          };
          servers = lib.mkOption {
            type = (
              lib.types.listOf (
                lib.types.submodule {
                  options = {
                    args = lib.mkOption {
                      type = (lib.types.listOf (lib.types.str));
                      default = [ ];
                      description = "Command arguments for stdio transport.";
                    };
                    command = lib.mkOption {
                      type = lib.types.str;
                      default = "";
                      description = "Executable to spawn for stdio transport.";
                    };
                    env = lib.mkOption {
                      type = (lib.types.attrsOf (lib.types.str));
                      default = { };
                      description = "Optional environment variables for stdio transport.";
                    };
                    headers = lib.mkOption {
                      type = (lib.types.attrsOf (lib.types.str));
                      default = { };
                      description = "Optional HTTP headers for HTTP/SSE transports.";
                    };
                    name = lib.mkOption {
                      type = lib.types.str;
                      default = "";
                      description = "Display name used as a tool prefix (`<server>__<tool>`).";
                    };
                    tool_timeout_secs = lib.mkOption {
                      type = lib.types.nullOr (lib.types.int);
                      default = 0;
                      description = "Optional per-call timeout in seconds (hard capped in validation).";
                    };
                    transport = lib.mkOption {
                      type = lib.types.str;
                      default = "stdio";
                      description = "Transport type for MCP server connections.";
                    };
                    url = lib.mkOption {
                      type = lib.types.nullOr (lib.types.str);
                      default = null;
                      description = "URL for HTTP/SSE transports.";
                    };
                  };
                }
              )
            );
            default = [ ];
            description = "Configured MCP servers.";
          };
        };
      };
      default = {
        deferred_loading = true;
        enabled = false;
        servers = [ ];
      };
      description = "External MCP client configuration (`[mcp]` section).";
    };
  };
}
