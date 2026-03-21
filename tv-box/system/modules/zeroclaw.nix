{
  config,
  sops-secrets,
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
        "web-search/brave-api-key" = openclawSecrets;
      };

    templates = {
      "zeroclaw-env" = {
        owner = config.services.zeroclaw.user;
        content = ''
          OPENAI_API_KEY=${config.sops.placeholder."models-keys/openai"}
          DEEPSEEK_API_KEY=${config.sops.placeholder."models-keys/deepseek"}
          OLLAMA_API_KEY=ollama-local
          BRAVE_API_KEY=${config.sops.placeholder."web-search/brave-api-key"}
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
    skillsSource = ../../../shared/agent-files/skills;
    workspaces = {
      workspace = {
        source = ../../../shared/agent-files/agents/main;

        skills = [
          "gitea"
          "nixos"
          "repositories"
          "self-improve"
          "ssh-keys"
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
        backend = "log";
      };

      http_request = {
        enabled = true;
        allow_private_hosts = true;
        allowed_domains = [ "*" ];
      };

      autonomy = {
        level = "full";
        allowed_commands = [
          "printenv"
          "which"
          "jq"
        ];
        auto_approve = [
          "file_write"
          "read_skill"
          "memory_store"
          "cron_add"
          "git_operations"
          "shell"
          "http_request"
        ];

        workspace_only = false;
        max_actions_per_hour = 100;
        block_high_risk_commands = false;
        require_approval_for_medium_risk = false;
        allowed_roots = [ "${config.services.zeroclaw.dataDir}" ];
        shell_env_passthrough = [
          "PRAXIS_GITEA_TOKEN"
        ];
      };

      cost = {
        enabled = true;
        prices = {
          "Deepseek/deepseek-reasoner" = {
            input = 0.28;
            output = 0.42;
          };
          "Deepseek/deepseek-chat" = {
            input = 0.28;
            output = 0.42;
          };
        };
      };

      agent = {
        compact_context = true;
        max_tool_iterations = 20;
      };

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
        builtin.command_logger = true;
      };

      security.sandbox = {
        enabled = false;
      };

      conversational_ai.default_language = "ru";

      browser.enabled = true;

      channels_config = {
        show_tool_calls = true;
        telegram = {
          bot_token = config.sops.placeholder."telegram/zeroclaw-token";
          allowed_users = [ "118569215" ];
        };
      };
    };
  };

}
