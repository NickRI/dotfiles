{ lib, ... }:
{
  options = {
    agent = lib.mkOption {
      type = lib.types.submodule {
        options = {
          compact_context = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "When true: bootstrap_max_chars=6000, rag_chunk_limit=2. Use for 13B or smaller models.";
          };
          max_context_tokens = lib.mkOption {
            type = lib.types.int;
            default = 32000;
            description = "Maximum estimated tokens for conversation history before compaction triggers.\nUses ~4 chars/token heuristic. When this threshold is exceeded, older messages\nare summarized to preserve context while staying within budget. Default: `32000`.";
          };
          max_history_messages = lib.mkOption {
            type = lib.types.int;
            default = 50;
            description = "Maximum conversation history messages retained per session. Default: `50`.";
          };
          max_tool_iterations = lib.mkOption {
            type = lib.types.int;
            default = 10;
            description = "Maximum tool-call loop turns per user message. Default: `10`.\nSetting to `0` falls back to the safe default of `10`.";
          };
          parallel_tools = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable parallel tool execution within a single iteration. Default: `false`.";
          };
          tool_call_dedup_exempt = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Tools exempt from the within-turn duplicate-call dedup check. Default: `[]`.";
          };
          tool_dispatcher = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = "Tool dispatch strategy (e.g. `\"auto\"`). Default: `\"auto\"`.";
          };
          tool_filter_groups = lib.mkOption {
            type = (
              lib.types.listOf (
                lib.types.submodule {
                  options = {
                    keywords = lib.mkOption {
                      type = (lib.types.listOf (lib.types.str));
                      default = [ ];
                      description = "Keywords that activate this group in `dynamic` mode (case-insensitive substring).\nIgnored when `mode = \"always\"`.";
                    };
                    mode = lib.mkOption {
                      type = lib.types.enum [
                        "always"
                        "dynamic"
                      ];
                      default = "dynamic";
                      description = "Determines when a `ToolFilterGroup` is active.";
                    };
                    tools = lib.mkOption {
                      type = (lib.types.listOf (lib.types.str));
                      default = [ ];
                      description = "Glob patterns matching MCP tool names (single `*` wildcard supported).";
                    };
                  };
                }
              )
            );
            default = [ ];
            description = "Per-turn MCP tool schema filtering groups.\n\nWhen non-empty, only MCP tools matched by an active group are included in the\ntool schema sent to the LLM for that turn. Built-in tools always pass through.\nDefault: `[]` (no filtering \u2014 all tools included).";
          };
        };
      };
      default = {
        compact_context = false;
        max_context_tokens = 32000;
        max_history_messages = 50;
        max_tool_iterations = 10;
        parallel_tools = false;
        tool_call_dedup_exempt = [ ];
        tool_dispatcher = "auto";
        tool_filter_groups = [ ];
      };
      description = "Agent orchestration configuration (`[agent]` section).";
    };
  };
}
