{ lib, ... }:
{
  options = {
    swarms = lib.mkOption {
      type = (
        lib.types.nullOr (
          lib.types.submodule {
            options = {
              agents = lib.mkOption {
                type = (lib.types.listOf (lib.types.str));
                default = [ ];
                description = "Ordered list of agent names (must reference keys in `agents`).";
              };
              description = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Optional description shown to the LLM when choosing swarms.";
              };
              router_prompt = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "System prompt for router strategy (used to pick the best agent).";
              };
              strategy = lib.mkOption {
                type = lib.types.enum [
                  "sequential"
                  "parallel"
                  "router"
                ];
                default = "sequential";
                description = "Orchestration strategy for a swarm of agents.";
              };
              timeout_secs = lib.mkOption {
                type = lib.types.int;
                default = 300;
                description = "Maximum total timeout for the swarm execution in seconds.";
              };
            };
          }
        )
      );
      default = null;
      description = "Swarm configurations for multi-agent orchestration.";
    };
  };
}
