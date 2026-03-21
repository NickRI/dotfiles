{ lib, ... }:
{
  options = {
    model_routes = lib.mkOption {
      type = (
        lib.types.listOf (
          lib.types.submodule {
            options = {
              api_key = lib.mkOption {
                type = lib.types.nullOr (lib.types.str);
                default = null;
                description = "Optional API key override for this route's provider";
              };
              hint = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Task hint name (e.g. \"reasoning\", \"fast\", \"code\", \"summarize\")";
              };
              model = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Model to use with that provider";
              };
              provider = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Provider to route to (must match a known provider name)";
              };
            };
          }
        )
      );
      default = [ ];
      description = "Model routing rules \u2014 route `hint:<name>` to specific provider+model combos.";
    };
  };
}
