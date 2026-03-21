{ lib, ... }:
{
  options = {
    query_classification = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable automatic query classification. Default: `false`.";
          };
          rules = lib.mkOption {
            type = (
              lib.types.listOf (
                lib.types.submodule {
                  options = {
                    hint = lib.mkOption {
                      type = lib.types.str;
                      default = "";
                      description = "Must match a `[[model_routes]]` hint value.";
                    };
                    keywords = lib.mkOption {
                      type = (lib.types.listOf (lib.types.str));
                      default = [ ];
                      description = "Case-insensitive substring matches.";
                    };
                    max_length = lib.mkOption {
                      type = lib.types.nullOr (lib.types.int);
                      default = 0;
                      description = "Only match if message length <= N chars.";
                    };
                    min_length = lib.mkOption {
                      type = lib.types.nullOr (lib.types.int);
                      default = 0;
                      description = "Only match if message length >= N chars.";
                    };
                    patterns = lib.mkOption {
                      type = (lib.types.listOf (lib.types.str));
                      default = [ ];
                      description = "Case-sensitive literal matches (for \"```\", \"fn \", etc.).";
                    };
                    priority = lib.mkOption {
                      type = lib.types.int;
                      default = 0;
                      description = "Higher priority rules are checked first.";
                    };
                  };
                }
              )
            );
            default = [ ];
            description = "Classification rules evaluated in priority order.";
          };
        };
      };
      default = {
        enabled = false;
        rules = [ ];
      };
      description = "Automatic query classification \u2014 classifies user messages by keyword/pattern\nand routes to the appropriate model hint. Disabled by default.";
    };
  };
}
