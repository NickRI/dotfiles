{ lib, ... }:
{
  options = {
    workspace = lib.mkOption {
      type = lib.types.submodule {
        options = {
          active_workspace = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Currently active workspace name.";
          };
          cross_workspace_search = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow searching across workspaces. Default: false (security).";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable workspace isolation. Default: false.";
          };
          isolate_audit = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Isolate audit logs per workspace. Default: true.";
          };
          isolate_memory = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Isolate memory databases per workspace. Default: true.";
          };
          isolate_secrets = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Isolate secrets namespaces per workspace. Default: true.";
          };
          workspaces_dir = lib.mkOption {
            type = lib.types.str;
            default = "~/.zeroclaw/workspaces";
            description = "Base directory for workspace profiles.";
          };
        };
      };
      default = {
        cross_workspace_search = false;
        enabled = false;
        isolate_audit = true;
        isolate_memory = true;
        isolate_secrets = true;
        workspaces_dir = "~/.zeroclaw/workspaces";
      };
      description = "Multi-client workspace isolation configuration.\n\nWhen enabled, each client engagement gets an isolated workspace with\nseparate memory, audit, secrets, and tool restrictions.";
    };
  };
}
