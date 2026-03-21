{ lib, ... }:
{
  options = {
    reliability = lib.mkOption {
      type = lib.types.submodule {
        options = {
          api_keys = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Additional API keys for round-robin rotation on rate-limit (429) errors.\nThe primary `api_key` is always tried first; these are extras.";
          };
          channel_initial_backoff_secs = lib.mkOption {
            type = lib.types.int;
            default = 2;
            description = "Initial backoff for channel/daemon restarts.";
          };
          channel_max_backoff_secs = lib.mkOption {
            type = lib.types.int;
            default = 60;
            description = "Max backoff for channel/daemon restarts.";
          };
          fallback_providers = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Fallback provider chain (e.g. `[\"anthropic\", \"openai\"]`).";
          };
          model_fallbacks = lib.mkOption {
            type = (lib.types.attrsOf ((lib.types.listOf (lib.types.str))));
            default = { };
            description = "Per-model fallback chains. When a model fails, try these alternatives in order.\nExample: `{ \"claude-opus-4-20250514\" = [\"claude-sonnet-4-20250514\", \"gpt-4o\"] }`";
          };
          provider_backoff_ms = lib.mkOption {
            type = lib.types.int;
            default = 500;
            description = "Base backoff (ms) for provider retry delay.";
          };
          provider_retries = lib.mkOption {
            type = lib.types.int;
            default = 2;
            description = "Retries per provider before failing over.";
          };
          scheduler_poll_secs = lib.mkOption {
            type = lib.types.int;
            default = 15;
            description = "Scheduler polling cadence in seconds.";
          };
          scheduler_retries = lib.mkOption {
            type = lib.types.int;
            default = 2;
            description = "Max retries for cron job execution attempts.";
          };
        };
      };
      default = {
        api_keys = [ ];
        channel_initial_backoff_secs = 2;
        channel_max_backoff_secs = 60;
        fallback_providers = [ ];
        model_fallbacks = { };
        provider_backoff_ms = 500;
        provider_retries = 2;
        scheduler_poll_secs = 15;
        scheduler_retries = 2;
      };
      description = "Reliability and supervision configuration (`[reliability]` section).\n\nControls provider retries, fallback chains, API key rotation, and channel restart backoff.";
    };
  };
}
