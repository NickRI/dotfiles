{ lib, ... }:
{
  options = {
    microsoft365 = lib.mkOption {
      type = lib.types.submodule {
        options = {
          auth_flow = lib.mkOption {
            type = lib.types.enum [
              "client_credentials"
              "device_code"
            ];
            default = "client_credentials";
            description = "Поток аутентификации Microsoft 365.";
          };
          client_id = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Azure AD application (client) ID";
          };
          client_secret = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Azure AD client secret (stored encrypted when secrets.encrypt = true)";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Microsoft 365 integration";
          };
          scopes = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "OAuth scopes to request";
          };
          tenant_id = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Azure AD tenant ID";
          };
          token_cache_encrypted = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Encrypt the token cache file on disk";
          };
          user_id = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "User principal name or \"me\" (for delegated flows)";
          };
        };
      };
      default = {
        auth_flow = "client_credentials";
        enabled = false;
        scopes = [ "https://graph.microsoft.com/.default" ];
        token_cache_encrypted = true;
      };
      description = "Microsoft 365 integration via Microsoft Graph API (`[microsoft365]` section).\n\nProvides access to Outlook mail, Teams messages, Calendar events,\nOneDrive files, and SharePoint search.";
    };
  };
}
