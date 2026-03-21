{ lib, ... }:
{
  options = {
    conversational_ai = lib.mkOption {
      type = lib.types.submodule {
        options = {
          analytics_enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable conversation analytics tracking. Default: false (privacy-by-default).";
          };
          auto_detect_language = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Automatically detect user language from message content. Default: true.";
          };
          conversation_timeout_secs = lib.mkOption {
            type = lib.types.int;
            default = 1800;
            description = "Conversation timeout in seconds (inactivity). Default: 1800.";
          };
          default_language = lib.mkOption {
            type = lib.types.str;
            default = "en";
            description = "Default language for conversations (BCP-47 tag). Default: \"en\".";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable conversational AI features. Default: false.";
          };
          escalation_confidence_threshold = lib.mkOption {
            type = lib.types.float;
            default = 0.3;
            description = "Intent confidence below this threshold triggers escalation. Default: 0.3.";
          };
          knowledge_base_tool = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional tool name for RAG-based knowledge base lookup during conversations.";
          };
          max_conversation_turns = lib.mkOption {
            type = lib.types.int;
            default = 50;
            description = "Maximum conversation turns before auto-ending. Default: 50.";
          };
          supported_languages = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Supported languages for conversations. Default: [`en`, `de`, `fr`, `it`].";
          };
        };
      };
      default = { };
      description = "Conversational AI agent builder configuration (`[conversational_ai]` section).\n\n**Status: Reserved for future use.** This configuration is parsed but not yet\nconsumed by the runtime. Setting `enabled = true` will produce a startup warning.";
    };
  };
}
