{ lib, ... }:
{
  options = {
    agents = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            agentic = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable agentic sub-agent mode (multi-turn tool-call loop).";
            };
            agentic_timeout_secs = lib.mkOption {
              type = lib.types.nullOr (lib.types.int);
              default = 0;
              description = "Timeout in seconds for agentic sub-agent loops.\nDefaults to 300 when unset. Must be between 1 and 3600.";
            };
            allowed_tools = lib.mkOption {
              type = (lib.types.listOf (lib.types.str));
              default = [ ];
              description = "Allowlist of tool names available to the sub-agent in agentic mode.";
            };
            api_key = lib.mkOption {
              type = lib.types.nullOr (lib.types.str);
              default = null;
              description = "Optional API key override";
            };
            max_depth = lib.mkOption {
              type = lib.types.int;
              default = 3;
              description = "Max recursion depth for nested delegation";
            };
            max_iterations = lib.mkOption {
              type = lib.types.int;
              default = 10;
              description = "Maximum tool-call iterations in agentic mode.";
            };
            model = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Model name";
            };
            provider = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Provider name (e.g. \"ollama\", \"openrouter\", \"anthropic\")";
            };
            system_prompt = lib.mkOption {
              type = lib.types.nullOr (lib.types.str);
              default = null;
              description = "Optional system prompt for the sub-agent";
            };
            temperature = lib.mkOption {
              type = lib.types.nullOr (lib.types.float);
              default = 0.0;
              description = "Temperature override";
            };
            timeout_secs = lib.mkOption {
              type = lib.types.nullOr (lib.types.int);
              default = 0;
              description = "Timeout in seconds for non-agentic provider calls.\nDefaults to 120 when unset. Must be between 1 and 3600.";
            };
          };
        }
      );
      default = null;
      description = "Delegate agent configurations for multi-agent workflows.";
    };
  };
}
