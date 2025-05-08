{ config, lib, ... }:

let
  gitea-listen-port = 6911;
  gitea-domain = "gitea.nas.firefly.red";
in
{
  acme.upstreams =
    [ ]
    ++ lib.optional (config.services.gitea.enable) {
      name = "gitea";
      domain = gitea-domain;
      local-port = gitea-listen-port;
    };

  monitoring.dashboards = lib.mkIf (config.services.gitea.enable) [
    {
      filename = "gitea_rev1.json";
    }
  ];

  services = {
    gitea = {
      repositoryRoot = "/storage/repositories";

      settings = {
        server = {
          HTTP_ADDR = "localhost";
          HTTP_PORT = gitea-listen-port;
          DOMAIN = gitea-domain;
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

    prometheus = lib.mkIf (config.services.gitea.enable) {
      scrapeConfigs = [
        {
          job_name = "gitea";
          static_configs = [
            {
              targets = [
                "localhost:${toString gitea-listen-port}"
              ];
            }
          ];
        }
      ];
    };
  };
}
