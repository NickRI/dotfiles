{ config, sops-secrets, ... }:

{
  sops.secrets =
    let
      openclaw.sopsFile = "${toString sops-secrets}/openclaw.yaml";
    in
    {
      "bots/telegram-token" = openclaw;
      "gateway-token" = openclaw;
      "models-keys" = openclaw;
      "agents/gitea-keys" = openclaw;
    };

  home.file = {
    ".openclaw/openclaw.json".force = true;
    ".ssh/config.d".source = ../files/openclaw/ssh-config.d;
  };

  programs.ssh.matchBlocks = {
    "*" = {
      extraConfig = ''
        Include ~/.ssh/config.d/*.conf
      '';
    };
  };

  systemd.user.services.openclaw-gateway.Service.EnvironmentFile = [
    config.sops.secrets."models-keys".path
    config.sops.secrets."agents/gitea-keys".path
  ];

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
        tokenFile = config.sops.secrets."bots/telegram-token".path;
        allowFrom = [ 118569215 ];
      };
    };
  };
}
