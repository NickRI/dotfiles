{ lib, ... }:
{
  options = {
    secrets = lib.mkOption {
      type = lib.types.submodule {
        options = {
          encrypt = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable encryption for API keys and tokens in config.toml";
          };
        };
      };
      default = {
        encrypt = true;
      };
      description = "Secrets encryption configuration (`[secrets]` section).";
    };
  };
}
