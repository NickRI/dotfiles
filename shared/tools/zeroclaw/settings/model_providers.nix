{ lib, ... }:
{
  options = {
    model_providers = lib.mkOption {
      type = (
        lib.types.nullOr (
          lib.types.submodule {
            options = {
              api_path = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Optional custom API path suffix (e.g. \"/v2/generate\" instead of the\ndefault \"/v1/chat/completions\"). Only used by OpenAI-compatible / custom providers.";
              };
              azure_openai_api_version = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Azure OpenAI API version (defaults to \"2024-08-01-preview\").";
              };
              azure_openai_deployment = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Azure OpenAI deployment name (e.g. \"gpt-4o\").";
              };
              azure_openai_resource = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Azure OpenAI resource name (e.g. \"my-resource\" in https://my-resource.openai.azure.com).";
              };
              base_url = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Optional base URL for OpenAI-compatible endpoints.";
              };
              name = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Optional provider type/name override (e.g. \"openai\", \"openai-codex\", or custom profile id).";
              };
              requires_openai_auth = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "If true, load OpenAI auth material (OPENAI_API_KEY or ~/.codex/auth.json).";
              };
              wire_api = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Provider protocol variant (\"responses\" or \"chat_completions\").";
              };
            };
          }
        )
      );
      default = null;
      description = "Optional named provider profiles keyed by id (Codex app-server compatible layout).";
    };
  };
}
