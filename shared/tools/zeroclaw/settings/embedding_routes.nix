{ lib, ... }:
{
  options = {
    embedding_routes = lib.mkOption {
      type = (
        lib.types.listOf (
          lib.types.submodule {
            options = {
              api_key = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Optional API key override for this route's provider";
              };
              dimensions = lib.mkOption {
                type = lib.types.nullOr (lib.types.int);
                default = 0;
                description = "Optional embedding dimension override for this route";
              };
              hint = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Route hint name (e.g. \"semantic\", \"archive\", \"faq\")";
              };
              model = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Embedding model to use with that provider";
              };
              provider = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Embedding provider (`none`, `openai`, or `custom:<url>`)";
              };
            };
          }
        )
      );
      default = [ ];
      description = "Embedding routing rules \u2014 route `hint:<name>` to specific provider+model combos.";
    };
  };
}
