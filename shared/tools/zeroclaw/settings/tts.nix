{ lib, ... }:
{
  options = {
    tts = lib.mkOption {
      type = lib.types.submodule {
        options = {
          default_format = lib.mkOption {
            type = lib.types.enum [
              "mp3"
              "opus"
              "wav"
            ];
            default = "mp3";
            description = "Default audio output format (`\"mp3\"`, `\"opus\"`, `\"wav\"`).";
          };
          default_provider = lib.mkOption {
            type = lib.types.enum [
              "openai"
              "elevenlabs"
              "google"
              "edge"
            ];
            default = "openai";
            description = "Default TTS provider (`\"openai\"`, `\"elevenlabs\"`, `\"google\"`, `\"edge\"`).";
          };
          default_voice = lib.mkOption {
            type = lib.types.str;
            default = "alloy";
            description = "Default voice ID passed to the selected provider.";
          };
          edge = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Edge TTS provider configuration (`[tts.edge]`).";
          };
          elevenlabs = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "ElevenLabs TTS provider configuration (`[tts.elevenlabs]`).";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable TTS synthesis.";
          };
          google = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Google Cloud TTS provider configuration (`[tts.google]`).";
          };
          max_text_length = lib.mkOption {
            type = lib.types.int;
            default = 4096;
            description = "Maximum input text length in characters (default 4096).";
          };
          openai = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "OpenAI TTS provider configuration (`[tts.openai]`).";
          };
        };
      };
      default = {
        default_format = "mp3";
        default_provider = "openai";
        default_voice = "alloy";
        enabled = false;
        max_text_length = 4096;
      };
      description = "Text-to-Speech configuration (`[tts]`).";
    };
  };
}
