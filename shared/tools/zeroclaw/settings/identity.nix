{ lib, ... }:
{
  options = {
    identity = lib.mkOption {
      type = lib.types.submodule {
        options = {
          aieos_inline = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Inline AIEOS JSON (alternative to file path)";
          };
          aieos_path = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Path to AIEOS JSON file (relative to workspace)";
          };
          format = lib.mkOption {
            type = lib.types.enum [
              "openclaw"
              "aieos"
            ];
            default = "openclaw";
            description = "Формат identity: `openclaw` или `aieos`.";
          };
        };
      };
      default = {
        format = "openclaw";
      };
      description = "Identity format configuration (`[identity]` section).\n\nSupports `\"openclaw\"` (default) or `\"aieos\"` identity documents.";
    };
  };
}
