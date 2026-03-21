{ lib, ... }:
{
  options = {
    channels_config = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            ack_reactions = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to add acknowledgement reactions (\ud83d\udc40 on receipt, \u2705/\u26a0\ufe0f on\ncompletion) to incoming channel messages. Default: `true`.";
            };
            bluesky = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Bluesky channel configuration (AT Protocol).";
            };
            clawdtalk = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "ClawdTalk voice channel configuration.";
            };
            cli = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable the CLI interactive channel. Default: `true`.";
            };
            dingtalk = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "DingTalk channel configuration.";
            };
            discord = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Discord bot channel configuration.";
            };
            email = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Email channel configuration.";
            };
            feishu = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Feishu channel configuration.";
            };
            imessage = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "iMessage channel configuration (macOS only).";
            };
            irc = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "IRC channel configuration.";
            };
            lark = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Lark channel configuration.";
            };
            linq = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Linq Partner API channel configuration.";
            };
            matrix = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Matrix channel configuration.";
            };
            mattermost = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Mattermost bot channel configuration.";
            };
            message_timeout_secs = lib.mkOption {
              type = lib.types.int;
              default = 300;
              description = "Base timeout in seconds for processing a single channel message (LLM + tools).\nRuntime uses this as a per-turn budget that scales with tool-loop depth\n(up to 4x, capped) so one slow/retried model call does not consume the\nentire conversation budget.\nDefault: 300s for on-device LLMs (Ollama) which are slower than cloud APIs.";
            };
            mochat = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Mochat customer service channel configuration.";
            };
            nextcloud_talk = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Nextcloud Talk bot channel configuration.";
            };
            nostr = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
            };
            qq = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "QQ Official Bot channel configuration.";
            };
            reddit = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Reddit channel configuration (OAuth2 bot).";
            };
            session_backend = lib.mkOption {
              type = lib.types.enum [
                "jsonl"
                "sqlite"
              ];
              default = "sqlite";
              description = "Session persistence backend: `jsonl` (legacy) or `sqlite` (по умолчанию; FTS5, TTL).";
            };
            session_persistence = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Persist channel conversation history to JSONL files so sessions survive\ndaemon restarts. Files are stored in `{workspace}/sessions/`. Default: `true`.";
            };
            session_ttl_hours = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = "Auto-archive stale sessions older than this many hours. `0` disables. Default: `0`.";
            };
            show_tool_calls = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to send tool-call notification messages (e.g. `\ud83d\udd27 web_search_tool: \u2026`)\nto channel users. When `false`, tool calls are still logged server-side but\nnot forwarded as individual channel messages. Default: `false`.";
            };
            signal = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Signal channel configuration.";
            };
            slack = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Slack bot channel configuration.";
            };
            telegram = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Telegram bot channel configuration.";
            };
            twitter = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "X/Twitter channel configuration.";
            };
            wati = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "WATI WhatsApp Business API channel configuration.";
            };
            webhook = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Webhook channel configuration.";
            };
            wecom = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "WeCom (WeChat Enterprise) Bot Webhook channel configuration.";
            };
            whatsapp = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "WhatsApp channel configuration (Cloud API or Web mode).";
            };
          };
        }
      );
      default = {
        ack_reactions = true;
        cli = true;
        message_timeout_secs = 300;
        session_backend = "sqlite";
        session_persistence = true;
        session_ttl_hours = 0;
        show_tool_calls = false;
      };
      description = "Top-level channel configurations (`[channels_config]` section).\n\nEach channel sub-section (e.g. `telegram`, `discord`) is optional;\nsetting it to `Some(...)` enables that channel.";
    };
  };
}
