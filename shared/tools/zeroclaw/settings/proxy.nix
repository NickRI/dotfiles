{ lib, ... }:
{
  options = {
    proxy = lib.mkOption {
      type = lib.types.submodule {
        options = {
          all_proxy = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Fallback proxy URL for all schemes.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable proxy support for selected scope.";
          };
          http_proxy = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Proxy URL for HTTP requests (supports http, https, socks5, socks5h).";
          };
          https_proxy = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Proxy URL for HTTPS requests (supports http, https, socks5, socks5h).";
          };
          no_proxy = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "No-proxy bypass list. Same format as NO_PROXY.";
          };
          scope = lib.mkOption {
            type = lib.types.str;
            default = "zeroclaw";
            description = "Proxy application scope \u2014 determines which outbound traffic uses the proxy.";
          };
          services = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Service selectors used when scope = \"services\".";
          };
        };
      };
      default = {
        enabled = false;
        no_proxy = [ ];
        scope = "zeroclaw";
        services = [ ];
      };
      description = "Proxy configuration for outbound HTTP/HTTPS/SOCKS5 traffic (`[proxy]` section).";
    };
  };
}
