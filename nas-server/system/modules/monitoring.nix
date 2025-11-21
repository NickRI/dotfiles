{
  config,
  lib,
  pkgs,
  ...
}:
let
  grafana-listen-port = 3000;
  grafana-domain = "grafana.nas.firefly.red";
  prometheus-listen-port = 9090;
  loki-listen-port = 3100;
  promtail-listen-port = 9080;
  scrutiny-listen-port = 8089;
in
{
  options.monitoring = {
    dashboards-path = lib.mkOption {
      type = lib.types.str;
      default = "grafana-dashboards";
      example = "grafana-dashboards";
    };
    dashboards = lib.mkOption {
      description = "List grafana dashboards";
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            filename = lib.mkOption {
              type = lib.types.str;
              example = "upstream";
            };
            user = lib.mkOption {
              type = lib.types.str;
              default = "grafana";
              example = "grafana";
            };
            group = lib.mkOption {
              type = lib.types.str;
              default = "grafana";
              example = "grafana";
            };
            mode = lib.mkOption {
              type = lib.types.str;
              default = "0444";
              example = "0444";
            };
          };
        }
      );
    };
  };

  config = {
    hosts.entries = {
      grafana = lib.mkIf (config.services.grafana.enable) {
        domain = grafana-domain;
        local-port = grafana-listen-port;
      };
      prometheus = lib.mkIf (config.services.prometheus.enable) {
        domain = "prometheus.nas.firefly.red";
        local-port = prometheus-listen-port;
      };
      scrutiny = lib.mkIf (config.services.scrutiny.enable) {
        domain = "scrutiny.nas.firefly.red";
        local-port = scrutiny-listen-port;
      };
    };

    monitoring.dashboards = lib.mkIf (config.services.grafana.enable) [
      {
        filename = "node-exporter-full-rev5.json";
      }
      {
        filename = "raid_mdadm_rev1.json";
      }
      {
        filename = "smartctl_exporter_rev1.json";
      }
    ];

    homepage.services.Infrastructure = {
      Grafana = lib.mkIf (config.services.grafana.enable) rec {
        description = "The open and composable observability platform";
        icon = "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/grafana-icon.svg";
        href = "https://grafana.nas.firefly.red/";
        siteMonitor = href;
      };
      Prometheus = lib.mkIf (config.services.prometheus.enable) rec {
        description = "Monitoring system & time series database";
        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prometheus.svg";
        href = "https://prometheus.nas.firefly.red/";
        siteMonitor = href;
      };
      Scrutiny = lib.mkIf (config.services.scrutiny.enable) rec {
        description = "WebUI for smartd S.M.A.R.T monitoring";
        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/scrutiny.svg";
        href = "https://scrutiny.nas.firefly.red/";
        siteMonitor = href;
      };
    };

    environment = lib.mkIf (config.services.grafana.enable) {
      systemPackages = with pkgs; [
        lm_sensors # needed for temperature
      ];
      etc = lib.listToAttrs (
        map (dashboard: {
          name = "${config.monitoring.dashboards-path}/${dashboard.filename}";
          value = {
            source = ../../files/${config.monitoring.dashboards-path}/${dashboard.filename};
            group = dashboard.group;
            user = dashboard.user;
            mode = dashboard.mode;
          };
        }) config.monitoring.dashboards
      );
    };

    services = {
      grafana = {
        settings = {
          server = {
            http_port = grafana-listen-port;
            # Grafana needs to know on which domain and URL it's running
            domain = grafana-domain;
          };
          users = {
            default_theme = "system";
            default_language = "en-EN";
            home_page = "/d/rYdddlPWk";
          };
          analytics = {
            check_for_plugin_updates = true;
            check_for_updates = true;
          };
        };
        provision = {
          enable = true;
          dashboards = {
            settings = {
              providers = [
                {
                  name = "My Dashboards";
                  options.path = "/etc/${config.monitoring.dashboards-path}";
                }
              ];
            };
          };
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://localhost:${toString prometheus-listen-port}";
            }
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://localhost:${toString loki-listen-port}";
            }
          ];
        };
      };

      prometheus = rec {
        listenAddress = "localhost";
        port = prometheus-listen-port;
        retentionTime = "7d";

        exporters = {
          node = {
            enable = true;
            listenAddress = listenAddress;
            port = 9091;
            enabledCollectors = [
              "logind"
              "systemd"
              "ethtool"
              "softirqs"
              "tcpstat"
              "wifi"
              "processes"
              "cpu"
              "loadavg"
              "filesystem"
              "interrupts"
              "zfs"
              "drm"
              "powersupplyclass"
            ];
          };
          smartctl = {
            enable = true;
            port = 9633;
            listenAddress = listenAddress;
          };
        };

        globalConfig = {
          scrape_interval = "15s";
          scrape_timeout = "5s";
        };

        # ingest the published nodes
        scrapeConfigs = [
          {
            job_name = "nodes";
            static_configs = [
              {
                targets = [
                  "${toString listenAddress}:${toString exporters.node.port}"
                ];
              }
            ];
          }
          {
            job_name = "smartctl";
            static_configs = [
              {
                targets = [
                  "${toString listenAddress}:${toString exporters.smartctl.port}"
                ];
              }
            ];
          }
        ];
      };

      loki = {
        configuration = {
          auth_enabled = false;
          analytics.reporting_enabled = false;
          server.http_listen_port = loki-listen-port;

          common = {
            instance_addr = "localhost";
            path_prefix = "/tmp/loki";
            ring.kvstore.store = "inmemory";
          };

          ingester = {
            lifecycler = {
              address = "localhost";
              ring = {
                kvstore = {
                  store = "inmemory";
                };
                replication_factor = 1;
              };
              final_sleep = "0s";
            };
            chunk_idle_period = "1h";
            max_chunk_age = "1h";
            chunk_target_size = 1048576;
            chunk_retain_period = "30s";
          };

          schema_config = {
            configs = [
              {
                from = "2024-04-25";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };

          storage_config = {
            tsdb_shipper = {
              active_index_directory = "/var/lib/loki/tsdb-shipper-active";
              cache_location = "/var/lib/loki/tsdb-shipper-cache";
              cache_ttl = "24h";
            };

            filesystem = {
              directory = "/var/lib/loki/chunks";
            };
          };

          limits_config = {
            reject_old_samples = true;
            reject_old_samples_max_age = "168h";
            retention_period = "168h";
            volume_enabled = true;
          };

          table_manager = {
            retention_deletes_enabled = true;
            retention_period = "168h";
          };

          compactor = {
            working_directory = "/var/lib/loki";
            compactor_ring = {
              kvstore = {
                store = "inmemory";
              };
            };
          };
        };
      };

      promtail = {
        configuration = {
          server = {
            http_listen_port = promtail-listen-port;
            grpc_listen_port = 0;
          };
          clients = [
            { url = "http://localhost:${toString loki-listen-port}/loki/api/v1/push"; }
          ];
        };
      };

      scrutiny = {
        settings.web.listen = {
          host = "localhost";
          port = scrutiny-listen-port;
        };
      };
    };
  };
}
