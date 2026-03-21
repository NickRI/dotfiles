{ lib, ... }:
{
  options = {
    plugins = lib.mkOption {
      type = lib.types.submodule {
        options = {
          auto_discover = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Auto-discover and load plugins on startup";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the plugin system (default: false)";
          };
          max_plugins = lib.mkOption {
            type = lib.types.int;
            default = 50;
            description = "Maximum number of plugins that can be loaded";
          };
          plugins_dir = lib.mkOption {
            type = lib.types.str;
            default = "~/.zeroclaw/plugins";
            description = "Directory where plugins are stored";
          };
        };
      };
      default = {
        auto_discover = false;
        enabled = false;
        max_plugins = 50;
        plugins_dir = "~/.zeroclaw/plugins";
      };
      description = "Plugin system configuration.";
    };
  };
}
