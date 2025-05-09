{ config, lib, ... }:

let
  gitea-listen-port = 6911;
  gitea-domain = "gitea.nas.firefly.red";
in
{
  hosts.entries = {
    gitea = lib.mkIf (config.services.gitea.enable) {
      domain = gitea-domain;
      local-port = gitea-listen-port;
    };
  };

  homepage.services.Development = {
    Gitea = lib.mkIf (config.services.gitea.enable) rec {
      description = "Open source content collaboration platform";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/gitea.svg";
      href = "https://gitea.nas.firefly.red/";
      siteMonitor = href;
    };
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
