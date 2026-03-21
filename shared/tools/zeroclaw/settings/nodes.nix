{ lib, ... }:
{
  options = {
    nodes = lib.mkOption {
      type = lib.types.submodule {
        options = {
          auth_token = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Optional bearer token for node authentication.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable dynamic node discovery endpoint.";
          };
          max_nodes = lib.mkOption {
            type = lib.types.int;
            default = 16;
            description = "Maximum number of concurrent node connections.";
          };
        };
      };
      default = {
        enabled = false;
        max_nodes = 16;
      };
      description = "Configuration for the dynamic node discovery system (`[nodes]`).\n\nWhen enabled, external processes/devices can connect via WebSocket\nat `/ws/nodes` and advertise their capabilities at runtime.";
    };
  };
}
