{
  config,
  sops-secrets,
  agents,
  lib,
  ...
}:

let
  zeroclaw-listen-port = 42618;
in
{
  imports = [
    ../../../shared/tools/zeroclaw
    ../../../shared/system/acme.nix
  ];

  hosts.enable = true;
  hosts.cloudflareEnvironmentFile = config.sops.secrets.cloudflare-env.path;
  hosts.external-interface = "192.168.1.116";
  hosts.entries = {
    zeroclaw = lib.mkIf (config.services.zeroclaw.enable) {
      domain = "zeroclaw.firefly.red";
      local-port = zeroclaw-listen-port;
    };
  };

  sops = {
    secrets =
      let
        openclawSecrets.sopsFile = "${toString sops-secrets}/openclaw.yaml";
      in
      {
        "telegram/zeroclaw-token" = openclawSecrets;
        "gateway-token" = openclawSecrets;
        "models-keys/openai" = openclawSecrets;
        "models-keys/deepseek" = openclawSecrets;
        "agents/gitea-keys" = openclawSecrets // {
          owner = config.services.zeroclaw.user;
        };
        "switch-ssh-access" = openclawSecrets;
        "services/brave-api-key" = openclawSecrets;
        "services/parcelsapp-api-key" = openclawSecrets;
        "cloudflare-env" = { };
      };

    templates = {
      "zeroclaw-env" = {
        owner = config.services.zeroclaw.user;
        content = ''
          OPENAI_API_KEY=${config.sops.placeholder."models-keys/openai"}
          DEEPSEEK_API_KEY=${config.sops.placeholder."models-keys/deepseek"}
          OLLAMA_API_KEY=ollama-local
          BRAVE_API_KEY=${config.sops.placeholder."services/brave-api-key"}
          PARCELSAPP_API_KEY=${config.sops.placeholder."services/parcelsapp-api-key"}
        '';
      };
    };
  };

  services.zeroclaw = {
    enable = true;
    secretsEnvFiles = [
      config.sops.templates."zeroclaw-env".path
      config.sops.secrets."agents/gitea-keys".path
    ];
    logLevel = "info";
    skillsSource = "${toString agents}/files/skills";
    workspaces = {
      workspace = {
        source = "${toString agents}/files/agents/main";

        skills = [
          "gitea"
          "github"
          "nixos"
          "self-improve"
          "ssh-keys"
          "scripts"
          "parcelsapp"
          "zeroclaw-shell"
          "zeroclaw-configure"
        ];
      };
    };

    settings = {
      default_provider = "deepseek";
      default_model = "deepseek-chat";
      gateway = {
        port = zeroclaw-listen-port;
      };

      observability = {
        runtime_trace_mode = "full";
        backend = "verbose";
      };

      http_request = {
        enabled = true;
        allow_private_hosts = true;
        allowed_domains = [ "*" ];
      };

      web_fetch = {
        enabled = true;
        allowed_domains = lib.mkForce [ "*" ];
      };

      web_search = {
        enabled = true;
        max_results = 7;
      };

      autonomy = {
        level = "supervised";
        allowed_commands = [
          "zeroclaw"
          "printenv"
          "which"
          "jq"
          "touch"
          "git"
          "cd"
          "sort"
          "python"
          "pip"
          "python3"
          "pip3"
          "mkdir"
          "mv"
          "cp"
          "chmod"
          "chown"
        ];
        auto_approve = [
          "file_edit"
          "file_write"
          "read_skill"
          "content_search"
          "memory_store"
          "memory_forget"
          "cron_add"
          "cron_list"
          "cron_run"
          "cron_runs"
          "cron_update"
          "image_info"
          "data_management"
          "git_operations"
          "shell"
          "http_request"
          "web_fetch"
          "web_search_tool"
          "browser"
          "tool_search"
          "glob_search"
          "knowledge"
          "delegate"
          "sessions_list"
          "sessions_history"
          "sessions_send"
          "backup"
        ];

        workspace_only = false;
        max_actions_per_hour = 100;
        block_high_risk_commands = true;
        require_approval_for_medium_risk = false;
        allowed_roots = [ "${config.services.zeroclaw.dataDir}" ];
        shell_env_passthrough = [
          "PRAXIS_GITEA_TOKEN"
          "PARCELSAPP_API_KEY"
        ];
      };

      data_retention.enabled = true;

      knowledge = {
        enabled = true;
        auto_capture = true;
        suggest_on_query = true;
        db_path = "${config.services.zeroclaw.dataDir}/workspace/knowledge/knowledge.db";
      };

      backup = {
        include_dirs = [
          "cron"
          "scripts"
        ];
      };

      cost = {
        enabled = true;
        prices = {
          "deepseek/deepseek-reasoner" = {
            input = 0.28;
            output = 0.42;
          };
          "deepseek/deepseek-chat" = {
            input = 0.28;
            output = 0.42;
          };
        };
      };

      agent = {
        compact_context = false;
        max_tool_iterations = 20;
        max_context_tokens = 64000;
      };

      model_routes = [
        {
          hint = "reasoning";
          model = "deepseek-reasoner";
          provider = "deepseek";
        }
      ];

      skills = {
        open_skills_enabled = false;
        open_skills_dir = "${config.services.zeroclaw.dataDir}/open-skills";
        prompt_injection_mode = "compact";
        skill_creation = {
          enabled = true;
        };
      };

      hooks = {
        enabled = true;
        builtin = {
          command_logger = true;
          webhook_audit = {
            enabled = false;
            include_args = false;
          };
        };
      };

      security.sandbox = {
        enabled = false;
      };

      memory = {
        embedding_provider = "custom:http://127.0.0.1:11434";
        embedding_model = "mxbai-embed-large:latest";
        embedding_dimensions = 1024;
      };

      conversational_ai.default_language = "ru";

      browser = {
        enabled = true;
        allowed_domains = [ "*" ];
      };

      channels_config = {
        ack_reactions = false;
        show_tool_calls = true;
        telegram = {
          bot_token = config.sops.placeholder."telegram/zeroclaw-token";
          allowed_users = [ "118569215" ];
        };
      };
    };
  };

}
