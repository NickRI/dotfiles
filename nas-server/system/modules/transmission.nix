{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = builtins.fromJSON (builtins.readFile ./config.json);

  transmission-listen-port = 5055;
  transmission-full-path = "${cfg.inner-interface}:${toString transmission-listen-port}";
in
{
  config = {
    security.acme.certs = {
      ${cfg.transmission-domain} = lib.mkIf (
        config.services.transmission.enable
        && config.services.nginx.virtualHosts."${cfg.transmission-domain}".enableACME
      ) config.security.acme.defaults;
    };

    sops = {
      secrets = {
        "nas/transmission/username" = { };
        "nas/transmission/password" = { };
      };

      templates."transmission.json" = {
        mode = "0644";
        content = ''
          {
                    "rpc-authentication-required": true,
                    "rpc-username": "${config.sops.placeholder."nas/transmission/username"}",
                    "rpc-password": "${config.sops.placeholder."nas/transmission/password"}"
                  }'';
      };
    };

    services = {
      transmission = {
        enable = true;

        webHome = pkgs.flood-for-transmission;

        credentialsFile = config.sops.templates."transmission.json".path;

        settings = {
          watch-dir = "/storage/transmission/watch";
          download-dir = "/storage/transmission/downloads";
          incomplete-dir = "/storage/transmission/incomplete";

          rpc-enabled = true;
          rpc-bind-address = cfg.inner-interface;
          rpc-port = transmission-listen-port;
          rpc-host-whitelist = "*";
        };

      };

      nginx = lib.mkIf (config.services.transmission.enable) {
        enable = true;
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        # recommendedTlsSettings = true;

        upstreams = {
          "transmission" = {
            servers = {
              "${transmission-full-path}" = { };
            };
          };
        };

        virtualHosts."${cfg.transmission-domain}" = {
          forceSSL = true;
          enableACME = true;

          locations."/" = {
            proxyPass = "http://transmission";
            proxyWebsockets = true;
          };

          listen = [
            {
              addr = cfg.external-interface;
              port = 80;
            }
            {
              addr = cfg.external-interface;
              port = 443;
              ssl = true;
            }
          ];
        };
      };
    };
  };
}
