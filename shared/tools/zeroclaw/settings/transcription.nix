{ lib, ... }:
{
  options = {
    transcription = lib.mkOption {
      type = lib.types.submodule {
        options = {
          api_key = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "API key used for transcription requests (Groq provider).\n\nIf unset, runtime falls back to `GROQ_API_KEY` for backward compatibility.";
          };
          api_url = lib.mkOption {
            type = lib.types.str;
            default = "https://api.groq.com/openai/v1/audio/transcriptions";
            description = "Whisper API endpoint URL (Groq provider).";
          };
          assemblyai = lib.mkOption {
            type = lib.types.submodule {
              options = {
                api_key = lib.mkOption {
                  type = lib.types.nullOr (lib.types.str);
                  default = null;
                  description = "AssemblyAI API key.";
                };
              };
            };
            default = { };
            description = "AssemblyAI STT provider configuration.";
          };
          deepgram = lib.mkOption {
            type = lib.types.submodule {
              options = {
                api_key = lib.mkOption {
                  type = lib.types.nullOr (lib.types.str);
                  default = null;
                  description = "Deepgram API key.";
                };
                model = lib.mkOption {
                  type = lib.types.str;
                  default = "nova-2";
                  description = "Deepgram model name.";
                };
              };
            };
            default = { };
            description = "Deepgram STT provider configuration.";
          };
          default_provider = lib.mkOption {
            type = lib.types.enum [
              "groq"
              "openai"
              "deepgram"
              "assemblyai"
              "google"
            ];
            default = "groq";
            description = "Провайдер STT по умолчанию.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable voice transcription for channels that support it.";
          };
          google = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
            default = { };
            description = "Google Cloud Speech-to-Text provider configuration.";
          };
          initial_prompt = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional initial prompt to bias transcription toward expected vocabulary\n(proper nouns, technical terms, etc.). Sent as the `prompt` field in the\nWhisper API request.";
          };
          language = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional language hint (ISO-639-1, e.g. \"en\", \"ru\") for Groq provider.";
          };
          max_duration_secs = lib.mkOption {
            type = lib.types.int;
            default = 120;
            description = "Maximum voice duration in seconds (messages longer than this are skipped).";
          };
          model = lib.mkOption {
            type = lib.types.str;
            default = "whisper-large-v3-turbo";
            description = "Whisper model name (Groq provider).";
          };
          openai = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
            default = { };
            description = "OpenAI Whisper STT provider configuration.";
          };
        };
      };
      default = {
        api_url = "https://api.groq.com/openai/v1/audio/transcriptions";
        default_provider = "groq";
        enabled = false;
        max_duration_secs = 120;
        model = "whisper-large-v3-turbo";
      };
      description = "Voice transcription configuration with multi-provider support.\n\nThe top-level `api_url`, `model`, and `api_key` fields remain for backward\ncompatibility with existing Groq-based configurations.";
    };
  };
}
