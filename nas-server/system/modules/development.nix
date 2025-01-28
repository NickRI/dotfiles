{config, lib, ...}:
let
  cfg = builtins.fromJSON (builtins.readFile ./config.json);

  gitea-listen-port = 6911;
  gitea-full-path = "${cfg.inner-interface}:${toString gitea-listen-port}";
  athens-listen-port = 6934;
  athens-full-path = "${cfg.inner-interface}:${toString athens-listen-port}";
in
{
  config = {

    environment.etc = lib.mkIf (config.services.grafana.enable && config.services.gitea.enable) {
      "${cfg.dashboards-dir}/gitea_rev1.json" = {
        source = ../../files/${cfg.dashboards-dir}/gitea_rev1.json;
        group = "grafana";
        user = "grafana";
        mode = "0444";
      };
    };

    security.acme.certs = {
      ${cfg.gitea-domain} = lib.mkIf (
        config.services.gitea.enable &&
        config.services.nginx.virtualHosts."${cfg.gitea-domain}".enableACME
      ) config.security.acme.defaults;
      ${cfg.athens-domain} = lib.mkIf (
        config.services.athens.enable &&
        config.services.nginx.virtualHosts."${cfg.athens-domain}".enableACME
      ) config.security.acme.defaults;
    };

    services = {
      gitea = {
        enable = true;
        repositoryRoot = "/storage/repositories";

        settings = {
          server = {
            HTTP_ADDR = cfg.inner-interface;
            HTTP_PORT = gitea-listen-port;
            DOMAIN = cfg.gitea-domain;
          };

          metrics = {
            ENABLED = true;
            ENABLED_ISSUE_BY_REPOSITORY = true;
            ENABLED_ISSUE_BY_LABEL = true;
          };

          "service.explore".REQUIRE_SIGNIN_VIEW = true;
          service.DISABLE_REGISTRATION = true;
          session.COOKIE_SECURE = true;
#          mailer = {
#
#          };
        };
      };

      athens = {
        enable = true;
        storage.disk.rootPath = "/storage/athens";
        port = athens-listen-port;
        logLevel = "info";
      };

      nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        # recommendedTlsSettings = true;

        upstreams = {
          "gitea" = lib.mkIf (config.services.gitea.enable) {
            servers = {
              "${gitea-full-path}" = {};
            };
          };
          "athens" = lib.mkIf (config.services.athens.enable) {
            servers = {
              "${athens-full-path}" = {};
            };
          };
        };

        virtualHosts."${cfg.gitea-domain}" = lib.mkIf (config.services.gitea.enable) {
          forceSSL = true;
          enableACME = true;

          locations."/" = {
            proxyPass = "http://gitea";
            proxyWebsockets = true;
          };

          listen = [
            { addr = cfg.external-interface; port = 80; }
            { addr = cfg.external-interface; port = 443; ssl = true; }
          ];
        };

        virtualHosts."${cfg.athens-domain}" = lib.mkIf (config.services.athens.enable) {
          forceSSL = true;
          enableACME = true;

          locations."/" = {
            proxyPass = "http://athens";
            proxyWebsockets = true;
          };

          listen = [
            { addr = cfg.external-interface; port = 80; }
            { addr = cfg.external-interface; port = 443; ssl = true; }
          ];
        };
      };

      prometheus = lib.mkIf (config.services.gitea.enable) {
        scrapeConfigs = [{
          job_name = "gitea";
          static_configs = [{
            targets = [
              gitea-full-path
            ];
          }];
        }];
      };
    };

  };

}