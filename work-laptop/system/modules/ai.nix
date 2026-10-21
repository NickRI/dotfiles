{ pkgs, lib, ... }:

let
  # Native OpenCode V2 provider config. Only local models are configured:
  # OpenCode discovers the Ollama models on its own.
  providers = {
    llama-swap = {
      name = "llama-swap (local)";
      package = "@opencode/ai/providers/openai-compatible";
      settings = {
        baseURL = "http://127.0.0.1:8080/v1";
        # Models are unloaded after ten minutes, so a cold start can take a
        # while. The default header timeout is five minutes.
        headerTimeout = 600000;
      };
      models = {
        "Qwen3.8-Coder-Flash-Next" = {
          modelID = "qwen3.8-flash-next-coder-iq1_m";
          name = "Qwen3.8 Flash Next Coder";
          capabilities = {
            tools = true;
            input = [ "text" ];
            output = [ "text" ];
          };
          limit = {
            context = 262144;
            output = 65536;
          };
          settings.reasoningEffort = "medium";
          variants = [
            {
              id = "low";
              settings.reasoningEffort = "low";
            }
            {
              id = "medium";
              settings.reasoningEffort = "medium";
            }
            {
              id = "high";
              settings.reasoningEffort = "high";
            }
            {
              id = "xhigh";
              settings.reasoningEffort = "xhigh";
            }
          ];
        };
        "Qwen3.8-Flash-Next" = {
          modelID = "qwen3.8-flash-next-iq2_xs";
          name = "Qwen3.8 Flash Next";
          capabilities = {
            tools = true;
            input = [ "text" ];
            output = [ "text" ];
          };
          limit = {
            context = 262144;
            output = 65536;
          };
          settings.reasoningEffort = "medium";
          variants = [
            {
              id = "low";
              settings.reasoningEffort = "low";
            }
            {
              id = "medium";
              settings.reasoningEffort = "medium";
            }
            {
              id = "high";
              settings.reasoningEffort = "high";
            }
            {
              id = "xhigh";
              settings.reasoningEffort = "xhigh";
            }
          ];
        };
      };
    };
  };

  settings = {
    # V2 keeps the provider and model but not a variant in the root default.
    model = "llama-swap/Qwen3.8-Flash-Next";

    # V2 allows access outside the project by default; keep the V1 behaviour.
    permissions = [
      {
        action = "external_directory";
        resource = "*";
        effect = "ask";
      }
    ];

    providers = providers;
  };

  # Render a programs.mcp server in the native V2 shape instead of the flat
  # V1 shape that Home Manager's OpenCode integration produces.
  toV2Server =
    _: server:
    let
      isRemote = server ? url && server.url != null;
      environment = lib.mapAttrs (
        _: value: if builtins.isAttrs value && value ? file then "{file:${value.file}}" else value
      ) (server.env or { });
    in
    {
      type = if isRemote then "remote" else "local";
    }
    // (
      if isRemote then
        {
          inherit (server) url;
        }
        // lib.optionalAttrs ((server.headers or { }) != { }) { inherit (server) headers; }
      else
        {
          command = [ server.command ] ++ (server.args or [ ]);
        }
        // lib.optionalAttrs (environment != { }) { inherit environment; }
    )
    // lib.optionalAttrs ((server.timeout or null) != null) { inherit (server) timeout; }
    // lib.optionalAttrs (!(server.enabled or true)) { disabled = true; };
in
{
  home-manager.users.nikolai =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ../../../shared/home/ai.nix ];

      home.packages = with pkgs.unstable; [
        nodejs
        code-cursor
        cursor-cli
      ];

      # Thunderbird cannot run elsewhere: it needs a running Thunderbird
      # instance on the user's session bus.
      programs.mcp.servers = {
        thunderbird = {
          command = lib.getExe pkgs.unstable.thunderbird-cli-mcp;
          enabled = true;
        };
      };

      programs.opencode = {
        enable = true;

        settings = settings // {
          # Unload idle locations (and the MCP servers they own) after ten
          # minutes. Running sessions, pending questions and background jobs
          # keep their location alive. V2 has no per-server MCP TTL.
          experimental.location_idle_timeout = "10 minutes";

          mcp = {
            timeout.startup = 45000;
            servers = lib.mapAttrs toV2Server config.programs.mcp.servers;
          };
        };

        agents = {
          architect = ../../../shared/files/agents/architect.md;
          developer = ../../../shared/files/agents/developer.md;
          reviewer = ../../../shared/files/agents/reviewer.md;
        };

        web = {
          enable = true;
          extraArgs = [
            "--service"
            "--hostname"
            "0.0.0.0"
            "--port"
            "1716"
            "--print-logs"
            "--log-level"
            "debug"
          ];
        };
      };

      # OpenCode V2 reads terminal settings from a single global cli.json
      # instead of tui.json, and Home Manager has no option for it.
      xdg.configFile."opencode/cli.json".source = (pkgs.formats.json { }).generate "cli.json" {
        "$schema" = "https://opencode.ai/v2/cli.json";
        theme = {
          name = "onedarkpro";
          mode = "system";
        };
      };
    };

  systemd.services.llama-swap = {
    path = [
      pkgs.rocmPackages.rocm-smi
    ];

    serviceConfig = {
      StateDirectory = null;
      CacheDirectory = null;
      DynamicUser = lib.mkForce false;
      User = "llama-swap";
      Group = "llama-swap";
      ReadWritePaths = [ "/var/lib/llama-swap" ];
      SupplementaryGroups = [
        "render"
        "video"
      ];
    };

    environment = {
      HOME = "/var/lib/llama-swap";
      XDG_CACHE_HOME = "/var/cache/llama-swap";
      HF_HOME = "/var/cache/llama-swap/huggingface";
      HF_HUB_CACHE = "/var/cache/llama-swap/huggingface/hub";
      LLAMA_CACHE = "/var/cache/llama-swap/huggingface/hub";
      MESA_SHADER_CACHE_DIR = "/var/cache/llama-swap/mesa";
    };
  };

  users.users.llama-swap = {
    isSystemUser = true;
    group = "llama-swap";
    extraGroups = [
      "render"
      "video"
    ];
  };

  users.groups.llama-swap = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/llama-swap 0755 llama-swap llama-swap -"
    "d /var/cache/llama-swap 0755 llama-swap llama-swap -"
    "d /var/cache/llama-cpp 0755 llama-swap llama-swap -"
  ];

  services = {
    llama-swap = {
      enable = true;
      settings = {
        healthCheckTimeout = 300;
        models = {
          "qwen3.8-flash-next-coder-iq1_m" = {
            cmd = "${pkgs.bash}/bin/sh -c 'cd /var/lib/llama-swap/strata && exec /var/lib/llama-swap/strata/.venv/bin/python serve/server.py --engine strata --config /var/lib/llama-swap/strata/strata-coder-iq1_m.json --port \${PORT}'";
            checkEndpoint = "/health";
            ttl = 600;
          };
          "qwen3.8-flash-next-iq2_xs" = {
            cmd = "${pkgs.bash}/bin/sh -c 'cd /var/lib/llama-swap/strata && exec /var/lib/llama-swap/strata/.venv/bin/python serve/server.py --engine strata --config /var/lib/llama-swap/strata/strata-iq2_xs.json --port \${PORT}'";
            checkEndpoint = "/health";
            ttl = 600;
          };
        };
      };
    };
    ollama = {
      enable = true;
      package = pkgs.unstable.ollama-rocm;
      environmentVariables = {
        OLLAMA_IGPU_ENABLE = "1";
        HSA_ENABLE_SDMA = "0";
        OLLAMA_DEBUG = "1";
      };

      group = [
        "video"
        "render"
      ];
    };
  };
}
