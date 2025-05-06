{ config, lib, ... }:

{
  options.acme = {
    external-interface = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.117";
      example = "192.168.1.xxx";
    };
    upstreams = lib.mkOption {
      description = "List acme nginx configuration";
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              example = "upstream";
            };
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
        map (upstream: {
          name = upstream.domain;
          value = defaults;
        }) config.acme.upstreams
      );
    };

    services.nginx = {
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      # recommendedTlsSettings = true;

      upstreams = lib.listToAttrs (
        map (upstream: {
          name = upstream.name;
          value = {
            servers = {
              "localhost:${toString upstream.local-port}" = { };
            };
          };
        }) config.acme.upstreams
      );

      virtualHosts = lib.listToAttrs (
        map (upstream: {
          name = upstream.domain;
          value = {
            forceSSL = true;
            enableACME = true;

            locations."/" = {
              proxyPass = "http://${upstream.name}";
              proxyWebsockets = true;
            };

            listen = [
              {
                addr = config.acme.external-interface;
                port = 80;
              }
              {
                addr = config.acme.external-interface;
                port = 443;
                ssl = true;
              }
            ];
          };
        }) config.acme.upstreams
      );
    };
  };
}
