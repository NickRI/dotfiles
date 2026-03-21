{ lib, ... }:
{
  options = {
    composio = lib.mkOption {
      type = lib.types.submodule {
        options = {
          api_key = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Composio API key (stored encrypted when secrets.encrypt = true)";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Composio integration for 1000+ OAuth tools";
          };
          entity_id = lib.mkOption {
            type = lib.types.str;
            default = "default";
            description = "Default entity ID for multi-user setups";
          };
        };
      };
      default = {
        enabled = false;
        entity_id = "default";
      };
      description = "Composio managed OAuth tools integration (`[composio]` section).\n\nProvides access to 1000+ OAuth-connected tools via the Composio platform.";
    };
  };
}
