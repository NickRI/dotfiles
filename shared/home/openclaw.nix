{ config, ... }:

{
  sops.secrets = {
    "openclaws/bot-token" = { };
    "openclaws/gateway-token" = { };
    "openclaws/env-keys" = { };
  };

  home.file = {
    ".openclaw/openclaw.json".force = true;
  };

  systemd.user.services.openclaw-gateway.Service.EnvironmentFile =
    config.sops.secrets."openclaws/env-keys".path;

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

      #      models = {
      #        providers = {
      #          openai = {
      #            enabled = true;
      #          };
      #        };
      #      };

      agents = {
        defaults = {
          model = {
            primary = "openai/gpt-5.1-codex";
            fallbacks = [ "openai/gpt-5.1-codex" ];
          };
        };
      };

      channels.telegram = {
        tokenFile = config.sops.secrets."openclaws/bot-token".path;
        allowFrom = [ 118569215 ];
      };
    };
  };
}
