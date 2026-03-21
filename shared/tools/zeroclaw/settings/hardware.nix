{ lib, ... }:
{
  options = {
    hardware = lib.mkOption {
      type = lib.types.submodule {
        options = {
          baud_rate = lib.mkOption {
            type = lib.types.int;
            default = 115200;
            description = "Serial baud rate";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether hardware access is enabled";
          };
          probe_target = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Probe target chip (e.g. \"STM32F401RE\")";
          };
          serial_port = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Serial port path (e.g. \"/dev/ttyACM0\")";
          };
          transport = lib.mkOption {
            type = lib.types.enum [
              "None"
              "Native"
              "Serial"
              "Probe"
            ];
            default = "None";
            description = "Режим транспорта hardware: `None`, `Native`, `Serial`, `Probe`.";
          };
          workspace_datasheets = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable workspace datasheet RAG (index PDF schematics for AI pin lookups)";
          };
        };
      };
      default = {
        baud_rate = 115200;
        enabled = false;
        transport = "None";
        workspace_datasheets = false;
      };
      description = "Wizard-driven hardware configuration for physical world interaction.";
    };
  };
}
