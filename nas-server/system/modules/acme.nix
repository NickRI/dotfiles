{ config, lib, ... }:

let
  upstream = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            example = "upstream";
            description = "Name of the upstream";
          };
        };
      }
    );
    default = null;
    description = "Optional upstream configuration";
  };
in
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
            upstream = upstream;
            domain = lib.mkOption {
              type = lib.types.str;
              example = "www.domain.com";
            };
            local-port = lib.mkOption {
              type = lib.types.int;
              example = 1921;
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
          name = entry.upstream.name;
          value = {
            servers = {
              "localhost:${toString entry.local-port}" = { };
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

            locations."/" = {
              proxyPass =
                if entry.upstream != null then
                  "http://${entry.upstream.name}"
                else
                  "http://127.0.0.1:${toString entry.local-port}";
              proxyWebsockets = true;
            };

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
