{ config, lib, ... }:

{

  options.hosts = {
    external-interface = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.117";
      example = "192.168.1.xxx";
    };
    entries = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            upstream = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Optional upstream configuration";
            };
            domain = lib.mkOption {
              type = lib.types.str;
              example = "www.domain.com";
            };
            local-port = lib.mkOption {
              type = lib.types.int;
              example = 1921;
            };
            location-extra-config = lib.mkOption {
              type = lib.types.str;
              default = "";
              example = "proxy_connect_timeout 30m;";
            };
            skip-root-location = lib.mkOption {
              type = lib.types.bool;
              default = false;
              example = true;
            };
            http2-support = lib.mkOption {
              type = lib.types.bool;
              default = true;
              example = false;
            };
            locations = lib.mkOption {
              type = lib.types.attrs;
              default = { };
              example = {
                "/" = {
                  proxyPass = "something:8080/v2";
                };
              };
            };
          };
        }
      );
      default = { };
      description = "List acme + nginx configuration.";
    };
  };

  config = {

    sops.secrets.cloudflare-env.owner = "acme";

    security.acme = lib.mkIf (config.services.nginx.enable) rec {
      acceptTerms = true;

      defaults = {
        group = "nginx";
        email = "admin@firefly.red";
        dnsProvider = "cloudflare";
        webroot = null;
        environmentFile = config.sops.secrets.cloudflare-env.path;
      };

      certs = lib.listToAttrs (
        builtins.map (entry: {
          name = entry.domain;
          value = defaults;
        }) (builtins.attrValues config.hosts.entries)
      );
    };

    services.nginx = {
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      # recommendedTlsSettings = true;

      upstreams = lib.listToAttrs (
        builtins.map (entry: {
          name = entry.upstream;
          value = {
            servers = {
              "127.0.0.1:${toString entry.local-port}" = { };
            };
          };
        }) (lib.filter (entry: entry.upstream != null) (builtins.attrValues config.hosts.entries))
      );

      virtualHosts = lib.listToAttrs (
        map (entry: {
          name = entry.domain;
          value = {
            forceSSL = true;
            enableACME = true;
            http2 = entry.http2-support;

            locations = {
              "/" = lib.mkIf (!entry.skip-root-location) {
                proxyPass =
                  if entry.upstream != null then
                    "http://${entry.upstream}"
                  else
                    "http://127.0.0.1:${toString entry.local-port}";
                proxyWebsockets = true;
                extraConfig = entry.location-extra-config;
              };
            }
            // (entry.locations or { });

            listen = [
              {
                addr = config.hosts.external-interface;
                port = 80;
              }
              {
                addr = config.hosts.external-interface;
                port = 443;
                ssl = true;
              }
            ];
          };
        }) (builtins.attrValues config.hosts.entries)
      );
    };
  };
}
