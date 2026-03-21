# Верхнеуровневые «простые» ключи конфига (раньше — отдельные *.nix на опцию).
{ lib, ... }:
{
  options = {
    api_key = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
      description = "API key for the selected provider. Overridden by `ZEROCLAW_API_KEY` or `API_KEY` env vars.";
    };
    api_path = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
      description = "Custom API path suffix for OpenAI-compatible / custom providers\n(e.g. \"/v2/generate\" instead of the default \"/v1/chat/completions\").";
    };
    api_url = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
      description = "Base URL override for provider API (e.g. \"http://10.0.0.1:11434\" for remote Ollama)";
    };
    default_model = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
      description = "Default model routed through the selected provider (e.g. `\"anthropic/claude-sonnet-4-6\"`).";
    };
    default_provider = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
      description = "Default provider ID or alias (e.g. `\"openrouter\"`, `\"ollama\"`, `\"anthropic\"`). Default: `\"openrouter\"`.";
    };
    default_temperature = lib.mkOption {
      type = lib.types.float;
      default = 0.7;
      description = "Default model temperature (0.0\u20132.0). Default: `0.7`.";
    };
    extra_headers = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Extra HTTP headers to include in LLM provider API requests.\n\nSome providers require specific headers (e.g., `User-Agent`, `HTTP-Referer`,\n`X-Title`) for request routing or policy enforcement. Headers defined here\naugment (and override) the program's default headers.\n\nCan also be set via `ZEROCLAW_EXTRA_HEADERS` environment variable using\nthe format `Key:Value,Key2:Value2`. Env var headers override config file headers.";
    };
    locale = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
      description = "Locale for tool descriptions (e.g. `\"en\"`, `\"zh-CN\"`).\n\nWhen set, tool descriptions shown in system prompts are loaded from\n`tool_descriptions/<locale>.toml`. Falls back to English, then to\nhardcoded descriptions.\n\nIf omitted or empty, the locale is auto-detected from `ZEROCLAW_LOCALE`,\n`LANG`, or `LC_ALL` environment variables (defaulting to `\"en\"`).";
    };
    provider_timeout_secs = lib.mkOption {
      type = lib.types.int;
      default = 120;
      description = "HTTP request timeout in seconds for LLM provider API calls. Default: `120`.\n\nIncrease for slower backends (e.g., llama.cpp on constrained hardware)\nthat need more time processing large contexts.";
    };
  };
}
