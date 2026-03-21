{ lib, ... }:
{
  options = {
    skills = lib.mkOption {
      type = lib.types.submodule {
        options = {
          open_skills_dir = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional path to a local open-skills repository.\nIf unset, defaults to `$HOME/open-skills` when enabled.";
          };
          open_skills_enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable loading and syncing the community open-skills repository.\nDefault: `false` (opt-in).";
          };
          prompt_injection_mode = lib.mkOption {
            type = lib.types.enum [
              "full"
              "compact"
            ];
            default = "full";
            description = "How skills are injected into the system prompt (`full` = legacy, `compact` = load on demand).";
          };
          skill_creation = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable automatic skill creation after successful multi-step tasks.\nDefault: `false`.";
                };
                max_skills = lib.mkOption {
                  type = lib.types.int;
                  default = 500;
                  description = "Maximum number of auto-generated skills to keep.\nWhen exceeded, the oldest auto-generated skill is removed (LRU eviction).";
                };
                similarity_threshold = lib.mkOption {
                  type = lib.types.float;
                  default = 0.85;
                  description = "Embedding similarity threshold for deduplication.\nSkills with descriptions more similar than this value are skipped.";
                };
              };
            };
            default = {
              enabled = false;
              max_skills = 500;
              similarity_threshold = 0.85;
            };
            description = "Autonomous skill creation configuration (`[skills.skill_creation]` section).";
          };
        };
      };
      default = {
        open_skills_enabled = false;
        prompt_injection_mode = "full";
        skill_creation = {
          enabled = false;
          max_skills = 500;
          similarity_threshold = 0.85;
        };
      };
      description = "Skills loading configuration (`[skills]` section).";
    };
  };
}
