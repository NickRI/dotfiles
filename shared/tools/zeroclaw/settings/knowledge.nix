{ lib, ... }:
{
  options = {
    knowledge = lib.mkOption {
      type = lib.types.submodule {
        options = {
          auto_capture = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Automatically capture knowledge from conversations. Default: false.";
          };
          cross_workspace_search = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow searching across workspaces (disabled by default for client data isolation).";
          };
          db_path = lib.mkOption {
            type = lib.types.str;
            default = "~/.zeroclaw/knowledge.db";
            description = "Path to the knowledge graph SQLite database.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the knowledge graph tool. Default: false.";
          };
          max_nodes = lib.mkOption {
            type = lib.types.int;
            default = 100000;
            description = "Maximum number of knowledge nodes. Default: 100000.";
          };
          suggest_on_query = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Proactively suggest relevant knowledge on queries. Default: true.";
          };
        };
      };
      default = {
        auto_capture = false;
        cross_workspace_search = false;
        db_path = "~/.zeroclaw/knowledge.db";
        enabled = false;
        max_nodes = 100000;
        suggest_on_query = true;
      };
      description = "Knowledge graph configuration for capturing and reusing expertise.";
    };
  };
}
