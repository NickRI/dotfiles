{ lib, ... }:
{
  options = {
    peripherals = lib.mkOption {
      type = lib.types.submodule {
        options = {
          boards = lib.mkOption {
            type = (
              lib.types.listOf (
                lib.types.submodule {
                  options = {
                    baud = lib.mkOption {
                      type = lib.types.int;
                      default = 115200;
                      description = "Baud rate for serial (default: 115200)";
                    };
                    board = lib.mkOption {
                      type = lib.types.str;
                      default = "";
                      description = "Board type: \"nucleo-f401re\", \"rpi-gpio\", \"esp32\", etc.";
                    };
                    path = lib.mkOption {
                      type = lib.types.nullOr (lib.types.str);
                      default = null;
                      description = "Path for serial: \"/dev/ttyACM0\", \"/dev/ttyUSB0\"";
                    };
                    transport = lib.mkOption {
                      type = lib.types.enum [
                        "serial"
                        "native"
                        "websocket"
                      ];
                      default = "serial";
                      description = "Транспорт платы: `serial`, `native`, `websocket`.";
                    };
                  };
                }
              )
            );
            default = [ ];
            description = "Board configurations (nucleo-f401re, rpi-gpio, etc.)";
          };
          datasheet_dir = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Path to datasheet docs (relative to workspace) for RAG retrieval.\nPlace .md/.txt files named by board (e.g. nucleo-f401re.md, rpi-gpio.md).";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable peripheral support (boards become agent tools)";
          };
        };
      };
      default = {
        boards = [ ];
        enabled = false;
      };
      description = "Peripheral board integration configuration (`[peripherals]` section).\n\nBoards become agent tools when enabled.";
    };
  };
}
