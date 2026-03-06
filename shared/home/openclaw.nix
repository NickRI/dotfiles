{ config, sops-secrets, ... }:

{
  sops.secrets =
    let
      openclaw.sopsFile = "${toString sops-secrets}/openclaw.yaml";
    in
    {
      "bots/telegram-token" = openclaw;
      "gateway-token" = openclaw;
      "models-keys/openai" = openclaw;
      "models-keys/deepseek" = openclaw;
      "agents/gitea-keys" = openclaw;
    };

  sops.templates = {
    "openclaw-env" = {
      path = "${config.home.homeDirectory}/.openclaw/.env";
      content = ''
        OPENAI_API_KEY=${config.sops.placeholder."models-keys/openai"}
        DEEPSEEK_API_KEY=${config.sops.placeholder."models-keys/deepseek"}
      '';
    };
  };

  home.file = {
    ".openclaw/openclaw.json".force = true;
    ".ssh/config.d".source = ../files/openclaw/ssh-config.d;
  };

  programs.ssh = {
    extraConfig = ''
      Include ~/.ssh/config.d/*.conf
    '';

    matchBlocks."*" = { };
  };

  systemd.user.services.openclaw-gateway = {
    Service.EnvironmentFile = [
      config.sops.secrets."agents/gitea-keys".path
    ];
    Install.WantedBy = [ "default.target" ];
  };

  programs.openclaw = {
    enable = true;

    config = {
      gateway = {
        mode = "local";
        auth = {
          token = "8nkj4uVVUVWDTBZwtvcyz7zE7aw78zTErXK3";
        };
        controlUi = {
          enabled = true;
          basePath = "/openclaw";
        };
      };

      web = {
        enabled = true;
        heartbeatSeconds = 60;
        reconnect = {
          initialMs = 2000;
          maxMs = 120000;
          factor = 1.4;
          jitter = 0.2;
          maxAttempts = 0;
        };
      };

      models = {
        mode = "merge";
        providers = {
          deepseek = {
            baseUrl = "https://api.deepseek.com";
            apiKey = {
              source = "env";
              provider = "default";
              id = "DEEPSEEK_API_KEY";
            };
            api = "openai-completions";
            models = [
              {
                id = "deepseek-chat";
                name = "DeepSeek Chat (V3.2)";
                reasoning = false;
                input = [ "text" ];
                cost = {
                  input = 0.00000028;
                  output = 0.00000042;
                  cacheRead = 0.000000028;
                  cacheWrite = 0.00000028;
                };
                contextWindow = 128000;
                maxTokens = 8192;
              }
              {
                id = "deepseek-reasoner";
                name = "DeepSeek Reasoner (V3.2)";
                reasoning = true;
                input = [ "text" ];
                cost = {
                  input = 0.00000028;
                  output = 0.00000042;
                  cacheRead = 0.000000028;
                  cacheWrite = 0.00000028;
                };
                contextWindow = 128000;
                maxTokens = 65536;
              }
            ];
          };
        };
      };

      agents = {
        defaults = {
          model = {
            primary = "deepseek/deepseek-chat";
            fallbacks = [ "deepseek/deepseek-reasoner" ];
          };
        };
      };

      channels.telegram = {
        tokenFile = config.sops.secrets."bots/telegram-token".path;
        allowFrom = [ 118569215 ];
      };
    };
  };
}
