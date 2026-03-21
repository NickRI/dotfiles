{ lib, ... }:
{
  options = {
    notion = lib.mkOption {
      type = lib.types.submodule {
        options = {
          api_key = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          database_id = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          input_property = lib.mkOption {
            type = lib.types.str;
            default = "Input";
          };
          max_concurrent = lib.mkOption {
            type = lib.types.int;
            default = 4;
          };
          poll_interval_secs = lib.mkOption {
            type = lib.types.int;
            default = 5;
          };
          recover_stale = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          result_property = lib.mkOption {
            type = lib.types.str;
            default = "Result";
          };
          status_property = lib.mkOption {
            type = lib.types.str;
            default = "Status";
          };
        };
      };
      default = {
        api_key = "";
        database_id = "";
        enabled = false;
        input_property = "Input";
        max_concurrent = 4;
        poll_interval_secs = 5;
        recover_stale = true;
        result_property = "Result";
        status_property = "Status";
      };
      description = "Notion integration configuration (`[notion]`).\n\nWhen `enabled = true`, the agent polls a Notion database for pending tasks\nand exposes a `notion` tool for querying, reading, creating, and updating pages.\nRequires `api_key` (or the `NOTION_API_KEY` env var) and `database_id`.";
    };
  };
}
