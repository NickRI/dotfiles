{ pkgs, lib, ... }@args:

let
  settings = {
    lsp = {
      gopls = {
        command = [ (lib.getExe pkgs.unstable.gopls) ];
        extensions = [ ".go" ];
      };
      nixd = {
        command = [ (lib.getExe pkgs.unstable.nixd) ];
        extensions = [ ".nix" ];
      };
      rust = {
        command = [ (lib.getExe pkgs.unstable.rust-analyzer) ];
        extensions = [ ".rs" ];
      };
      pyright = {
        command = [
          (lib.getExe' pkgs.unstable.pyright "pyright-langserver")
          "--stdio"
        ];
        extensions = [
          ".py"
          ".pyi"
        ];
      };
      bash = {
        command = [
          (lib.getExe' pkgs.unstable.bash-language-server "bash-language-server")
          "start"
        ];
        extensions = [
          ".sh"
          ".bash"
          ".zsh"
          ".ksh"
        ];
      };
    };
    provider = {
      llama-swap = {
        name = "llama-swap (local)";
        npm = "@ai-sdk/openai-compatible";
        options = {
          baseURL = "http://127.0.0.1:8080/v1";
        };
        models = {
          "Qwen3.8-Coder-Flash-Next" = {
            id = "qwen3.8-flash-next-coder-iq1_m";
            name = "Qwen3.8 Flash Next Coder";
            options.reasoningEffort = "medium";
            limit = {
              context = 262144;
              output = 65536;
            };
            variants = {
              low = {
                reasoningEffort = "low";
              };
              medium = {
                reasoningEffort = "medium";
              };
              high = {
                reasoningEffort = "high";
              };
              xhigh = {
                reasoningEffort = "xhigh";
              };
            };
          };
          "Qwen3.8-Flash-Next" = {
            id = "qwen3.8-flash-next-iq2_xs";
            name = "Qwen3.8 Flash Next";
            options.reasoningEffort = "medium";
            limit = {
              context = 262144;
              output = 65536;
            };
            variants = {
              low = {
                reasoningEffort = "low";
              };
              medium = {
                reasoningEffort = "medium";
              };
              high = {
                reasoningEffort = "high";
              };
              xhigh = {
                reasoningEffort = "xhigh";
              };
            };
          };
        };
      };
      openrouter = {
        name = "OpenRouter Free";
        npm = "@ai-sdk/openai-compatible";
        options = {
          baseURL = "https://openrouter.ai/api/v1";
        };
        models = {
          Gemma-4-26B-Explore = {
            id = "google/gemma-4-26b-a4b-it:free";
            name = "Gemma 4 26B A4B — Explore";
            limit = {
              context = 262144;
              output = 32768;
            };
          };
          "Nemotron-3.5-Lightning-Scout" = {
            id = "nvidia/nemotron-3.5-lightning:free";
            name = "Nemotron 3.5 Lightning — Scout";
            limit = {
              context = 262144;
              output = 65536;
            };
          };
          Nemotron-3-Super-General = {
            id = "nvidia/nemotron-3-super-120b-a12b:free";
            name = "Nemotron 3 Super — General";
            limit = {
              context = 262144;
              output = 65536;
            };
          };
          Gemma-4-31B-Review = {
            id = "google/gemma-4-31b-it:free";
            name = "Gemma 4 31B — Review";
            limit = {
              context = 262144;
              output = 32768;
            };
          };
        };
      };
    };
  };
in
{
  home-manager.users.nikolai = { ... }: {
    imports = [ ../../../shared/home/ai.nix ];

    home.packages = with pkgs.unstable; [
      nodejs
      code-cursor
      cursor-cli
    ];

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;

      tui = {
        theme = "onedarkpro";
        enableChat = true;
        enableTerminal = true;
        enableFileExplorer = true;
      };

      web = {
        enable = true;
        extraArgs = [
          "--hostname"
          "0.0.0.0"
          "--port"
          "1716"
          "--print-logs"
          "--log-level"
          "debug"
        ];
      };

      settings = settings;
      agents = {
        architect = ../../../shared/files/agents/architect.md;
        developer = ../../../shared/files/agents/developer.md;
        reviewer = ../../../shared/files/agents/reviewer.md;
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
            ttl = 1800;
          };
          "qwen3.8-flash-next-iq2_xs" = {
            cmd = "${pkgs.bash}/bin/sh -c 'cd /var/lib/llama-swap/strata && exec /var/lib/llama-swap/strata/.venv/bin/python serve/server.py --engine strata --config /var/lib/llama-swap/strata/strata-iq2_xs.json --port \${PORT}'";
            checkEndpoint = "/health";
            ttl = 1800;
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
