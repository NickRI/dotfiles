{ config, lib, ... }:
with lib;
let
  homepage-listen-port = 8083;

  serviceEntry = types.submodule {
    options = {
      description = mkOption {
        type = types.str;
        description = "Description of the service.";
      };
      icon = mkOption {
        type = types.str;
        description = "URL to the service icon.";
      };
      href = mkOption {
        type = types.str;
        description = "Service URL.";
      };
      siteMonitor = mkOption {
        type = types.str;
        default = "";
        description = "URL for monitoring the site.";
      };
    };
  };
in
{
  options.homepage.services = lib.mkOption {
    type = types.attrsOf (types.attrsOf serviceEntry);
    default = { };
    description = "Custom service categories and entries.";
  };

  config = {
    hosts.entries = {
      homepage = lib.mkIf (config.services.homepage-dashboard.enable) {
        domain = "home.nas.firefly.red";
        local-port = homepage-listen-port;
      };
    };

    services = {
      homepage-dashboard = {
        listenPort = homepage-listen-port;

        services = builtins.map (category: {
          "${category}" = builtins.map (service: {
            "${service}" = config.homepage.services."${category}"."${service}";
          }) (builtins.attrNames config.homepage.services."${category}");

        }) (builtins.attrNames config.homepage.services);

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
                HomePage = [
                  {
                    abbr = "HPG";
                    icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/homepage.png";
                    href = "https://gethomepage.dev/";
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
  };
}
