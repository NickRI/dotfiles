{ pkgs, lib, ... }@args:

let
  settings = {
    lsp = true;
    provider = {
      llamacpp = {
        name = "llama-server (local)";
        npm = "@ai-sdk/openai-compatible";
        options = {
          baseURL = "http://127.0.0.1:8080/v1";
        };
        models = {
          Qwen3-Coder-30B-A3B = {
            id = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M";
            name = "Qwen3-Coder 30B A3B";
            limit = {
              context = 131072;
              output = 65536;
            };
          };
          Qwen3-30B-A3B-Thinking = {
            id = "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q4_K_M";
            name = "Qwen3 30B A3B (Thinking)";
            limit = {
              context = 131072;
              output = 65536;
            };
          };
          Qwen3-6-35B-A3B-MTP = {
            id = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:Q4_K_M";
            name = "Qwen3.6 35B A3B (MTP)";
            limit = {
              context = 131072;
              output = 65536;
            };
          };
          Nemotron-Cascade-2-30B-A3B-i1 = {
            id = "mradermacher/Nemotron-Cascade-2-30B-A3B-i1-GGUF";
            name = "Nemotron Cascade 2 30B A3B (i1)";
            limit = {
              context = 131072;
              output = 65536;
            };
          };
          "Qwen3.5-Coder-9B" = {
            id = "mradermacher/Qwen3.5-9B-Coder-GGUF:Q4_K_M";
            name = "Qwen3.5-Coder 9B";
            limit = {
              context = 131072;
              output = 65536;
            };
          };
          "Jev-Style-Qwen3.5-2B-Decision" = {
            id = "chaoliangUNSW/Jev-Style-Qwen3.5-2B-Decision-GGUF:Q4_K_M";
            name = "Qwen3.5 Jev Decision";
            limit = {
              context = 131072;
              output = 65536;
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
    agent = {
      build = {
        description = "Main - purpose gent with full access to the local files and tools.";
        mode = "primary";
        model = "llamacpp/Qwen3-Coder-30B-A3B";
        color = "primary";
        permission = {
          task = {
            "*" = "ask";
            explore = "allow";
            scout = "allow";
            general = "allow";
            architect = "allow";
            developer = "allow";
            reviewer = "allow";
          };
        };
        tools = {
          write = true;
          edit = true;
          bash = true;
        };
      };
      plan = {
        description = "Analyze the codebase and create implementation plans without making changes.";
        mode = "primary";
        model = "llamacpp/Qwen3-Coder-30B-A3B";
        color = "warning";
        permission = {
          read = "allow";
          glob = "allow";
          grep = "allow";
          list = "allow";
          edit = "deny";
          bash = "deny";
          task = {
            explore = "allow";
            scout = "ask";
            architect = "ask";
            developer = "ask";
            reviewer = "ask";
            general = "deny";
          };
        };
      };
      explore = {
        description = "Fast read-only agent for exploring the codebase, finding files, symbols and relevant implementations.";
        mode = "subagent";
        model = "openrouter/Gemma-4-26B-Explore";
        temperature = 0.1;
        steps = 6;
        tools = {
          write = false;
          edit = false;
          bash = false;
        };
      };
      scout = {
        description = "Read-only agent for researching external documentation, dependencies and upstream source code.";
        mode = "subagent";
        model = "openrouter/Nemotron-3.5-Lightning-Scout";
        temperature = 0.1;
        steps = 8;
        tools = {
          write = false;
          edit = false;
        };
      };
      general = {
        description = "General-purpose subagent for complex multi-step technical research and analysis.";
        mode = "subagent";
        model = "openrouter/Nemotron-3-Super-General";
        temperature = 0.2;
        steps = 12;
        tools = {
          write = false;
          edit = false;
          bash = false;
        };
      };
      architect = {
        model = "llamacpp/Qwen3.5-Coder-9B";
      };
      developer = {
        model = "llamacpp/Qwen3-Coder-30B-A3B";
      };
      reviewer = {
        model = "llamacpp/Qwen3.5-Coder-9B";
      };
    };
  };
in
{
  home-manager.users.nikolai = { ... }: {
    programs.opencode = {
      enable = true;

      tui = {
        theme = "onedarkpro";
        enableChat = true;
        enableTerminal = true;
        enableFileExplorer = true;
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
      settings =
        let
          llama-cpp = pkgs.llama-cpp-rocm;
          llama-server = lib.getExe' llama-cpp "llama-server";
        in
        {
          healthCheckTimeout = 60;
          models = {
            "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M" = {
              cmd = "${llama-server} --port \${PORT} -hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M -lv 4 --no-warmup --offline --parallel 2 -fa on --jinja --no-mmap --fit off -c 131072 --no-webui";
            };
            "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:Q4_K_M" = {
              cmd = "${llama-server} --port \${PORT} -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:Q4_K_M -lv 4 --no-warmup --offline --parallel 2 -fa on --jinja --no-mmap --fit off -c 131072 --no-webui";
            };
            "unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q4_K_M" = {
              cmd = "${llama-server} --port \${PORT} -hf unsloth/Qwen3-30B-A3B-Thinking-2507-GGUF:Q4_K_M -lv 4 --no-warmup --offline --parallel 2 -fa on --jinja --no-mmap --fit off -c 131072 --no-webui";
            };
            "mradermacher/Nemotron-Cascade-2-30B-A3B-i1-GGUF:Q4_K_M" = {
              cmd = "${llama-server} --port \${PORT} -hf mradermacher/Nemotron-Cascade-2-30B-A3B-i1-GGUF:Q4_K_M -lv 4 --no-warmup --offline --parallel 1 -fa on --jinja --no-mmap --fit off -c 131072 --no-webui";
            };
            "mradermacher/Qwen3.5-9B-Coder-GGUF:Q4_K_M" = {
              cmd = "${llama-server} --port \${PORT} -hf mradermacher/Qwen3.5-9B-Coder-GGUF:Q4_K_M -lv 4 --no-warmup --offline --parallel 1 -fa on --jinja --no-mmap --fit off -c 131072 --no-webui";
            };
            "chaoliangUNSW/Jev-Style-Qwen3.5-2B-Decision-GGUF:Q4_K_M" = {
              cmd = "${llama-server} --port \${PORT} -hf chaoliangUNSW/Jev-Style-Qwen3.5-2B-Decision-GGUF:Q4_K_M -lv 4 --no-warmup --offline --parallel 1 -fa on --jinja --no-mmap --fit off -c 131072 --no-webui";
            };
          };
          groups = {
            main = {
              swap = false;
              exclusive = false;
              persistent = true;
              members = [
                "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M"
                "mradermacher/Qwen3.5-9B-Coder-GGUF:Q4_K_M"
              ];
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
