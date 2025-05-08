{ config, lib, ... }:
let
  homepage-listen-port = 8083;
in
{

  acme.upstreams = lib.mkIf (config.services.homepage-dashboard.enable) [
    {
      name = "homepage";
      domain = "nas.firefly.red";
      local-port = homepage-listen-port;
    }
    {
      name = "homepage";
      domain = "home.nas.firefly.red";
      local-port = homepage-listen-port;
    }
  ];

  services = {
    homepage-dashboard = {
      listenPort = homepage-listen-port;

      services = [
        {
          Infrastructure = [
            {
              Grafana = lib.mkIf (config.services.grafana.enable) rec {
                description = "The open and composable observability platform";
                icon = "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/grafana-icon.svg";
                href = "https://grafana.nas.firefly.red/";
                siteMonitor = href;
              };
            }
            {
              Prometheus = lib.mkIf (config.services.prometheus.enable) rec {
                description = "Monitoring system & time series database";
                icon = "https://www.svgrepo.com/download/354219/prometheus.svg";
                href = "https://prometheus.nas.firefly.red/";
                siteMonitor = href;
              };
            }
            {
              Scrutiny = lib.mkIf (config.services.scrutiny.enable) rec {
                description = "WebUI for smartd S.M.A.R.T monitoring";
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/scrutiny.svg";
                href = "https://scrutiny.nas.firefly.red/";
                siteMonitor = href;
              };
            }
          ];
        }
        {
          Development = [
            {
              Gitea = lib.mkIf (config.services.gitea.enable) rec {
                description = "Open source content collaboration platform";
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/gitea.svg";
                href = "https://gitea.nas.firefly.red/";
                siteMonitor = href;
              };
            }
            {
              Athens = lib.mkIf (config.services.athens.enable) rec {
                description = "A Go module datastore and proxy";
                icon = "https://www.svgrepo.com/download/215353/parthenon-athens.svg";
                href = "https://athens.nas.firefly.red/";
                siteMonitor = href;
              };
            }
          ];
        }
        {
          Services = [
            {
              Nextcloud = lib.mkIf (config.services.nextcloud.enable) rec {
                description = "Open source content collaboration platform";
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/nextcloud.svg";
                href = "https://nextcloud.nas.firefly.red/";
                siteMonitor = href;
              };
            }
            {
              Transmission = lib.mkIf (config.services.transmission.enable) rec {
                description = "A fast, easy and free Bittorrent client for macOS, Windows and Linux";
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/transmission.svg";
                href = "https://transmission.nas.firefly.red/";
                siteMonitor = href;
              };
            }
            {
              Bitmagnet = lib.mkIf (config.services.bitmagnet.enable) rec {
                description = "A self-hosted BitTorrent indexer, DHT crawler";
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/bitmagnet.png";
                href = "https://bitmagnet.nas.firefly.red/";
                siteMonitor = href;
              };
            }
          ];
        }
      ];

      bookmarks = [
        {
          Developer = [
            {
              Github = [
                {
                  abbr = "GH";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/github.svg";
                  href = "https://github.com/";
                }
              ];
            }
            {
              Libhunt = [
                {
                  abbr = "GLH";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/wiki-go.svg";
                  href = "https://go.libhunt.com/";
                }
              ];
            }

          ];
        }
        {
          Infra = [
            {
              "Cloudflare Dashboard" = [
                {
                  abbr = "CF";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/cloudflare.svg";
                  href = "https://dash.cloudflare.com";
                }
              ];
            }
            {
              "Firefly.red DNS" = [
                {
                  abbr = "DNS";
                  href = "https://dash.cloudflare.com/4b4a216b5405d6cceeeba24099d90a06/firefly.red/dns/records";
                }
              ];
            }
            {
              "1password" = [
                {
                  abbr = "1PS";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/1password.svg";
                  href = "https://my.1password.com";
                }
              ];
            }
            {
              Selfhost = [
                {
                  abbr = "SLH";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/selfh-st.svg";
                  href = "https://selfh.st";
                }
              ];
            }
            {
              "Openai Platform" = [
                {
                  abbr = "OAI";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/chatgpt.svg";
                  href = "https://platform.openai.com/";
                }
              ];
            }
            {
              "Get ncps pubkey" = [
                {
                  abbr = "NCPS";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/nixos.svg";
                  href = "https://ncps.nas.firefly.red";
                }
              ];
            }
          ];
        }
        {
          Misc = [
            {
              Chatgpt = [
                {
                  abbr = "GPT";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/chatgpt.svg";
                  href = "https://chat.openai.com";
                }
              ];
            }
            {
              Deepseek = [
                {
                  abbr = "DSK";
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/deepseek.svg";
                  href = "https://chat.deepseek.com";
                }
              ];
            }
          ];
        }
        {
          Entertainment = [
            {
              YouTube = [
                {
                  abbr = "YT";
                  icon = "https://www.logo.wine/a/logo/YouTube/YouTube-Icon-Full-Color-Logo.wine.svg";
                  href = "https://youtube.com/";
                }
              ];
            }
          ];
        }
      ];

      widgets = [
        {
          resources = {
            cpu = true;
            cputemp = true;
            uptime = true;
            memory = true;
            network = true;
          };
        }
        {
          resources = {
            label = "System";
            disk = "/";
          };
        }
        {
          resources = {
            label = "Storage";
            disk = "/storage";
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
        {
          datetime = {
            text_size = "xl";
            format = {
              dateStyle = "short";
              timeStyle = "short";
              hourCycle = "h24";
            };
          };
        }
      ];

      settings = {
        theme = "dark";
        color = "zinc";
        background = {
          image = "https://unsplash.it/1920/1080/?random";
          blur = "xs";
          opacity = 20;
        };
      };
    };
  };

}
