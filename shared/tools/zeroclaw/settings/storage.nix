{ lib, ... }:
{
  options = {
    storage = lib.mkOption {
      type = lib.types.submodule {
        options = {
          provider = lib.mkOption {
            type = lib.types.submodule {
              options = {
                config = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      connect_timeout_secs = lib.mkOption {
                        type = lib.types.nullOr (lib.types.int);
                        default = 0;
                        description = "Optional connection timeout in seconds for remote providers.";
                      };
                      db_url = lib.mkOption {
                        type = lib.types.nullOr (lib.types.str);
                        default = null;
                        description = "Connection URL for remote providers.\nAccepts legacy aliases: dbURL, database_url, databaseUrl.";
                      };
                      provider = lib.mkOption {
                        type = lib.types.enum [
                          "postgres"
                          "sqlite"
                        ];
                        default = "sqlite";
                        description = "Storage engine key (e.g. \"postgres\", \"sqlite\").";
                      };
                      schema = lib.mkOption {
                        type = lib.types.str;
                        default = "public";
                        description = "Database schema for SQL backends.";
                      };
                      table = lib.mkOption {
                        type = lib.types.str;
                        default = "memories";
                        description = "Table name for memory entries.";
                      };
                    };
                  };
                  default = {
                    schema = "public";
                    table = "memories";
                  };
                  description = "Storage provider backend configuration (e.g. postgres connection details).";
                };
              };
            };
            default = {
              config = {
                schema = "public";
                table = "memories";
              };
            };
            description = "Wrapper for the storage provider configuration section.";
          };
        };
      };
      default = {
        provider = {
          config = {
            schema = "public";
            table = "memories";
          };
        };
      };
      description = "Persistent storage configuration (`[storage]` section).";
    };
  };
}
