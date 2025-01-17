{config, lib, ...}:

let
  cfg = builtins.fromJSON (builtins.readFile ./config.json);

  grafana-listen-port = 3000;
  prometheus-listen-port = 9090;
  loki-listen-port = 3100;
  promtail-listen-port = 9080;
  grafana-full-path = "${cfg.inner-interface}:${toString grafana-listen-port}";
  prometheus-full-path = "${cfg.inner-interface}:${toString prometheus-listen-port}";
  loki-full-path = "${cfg.inner-interface}:${toString loki-listen-port}";
in
{
  config = {

    environment.etc = lib.mkIf (config.services.grafana.enable) {
      "${cfg.dashboards-dir}/node-exporter-full-rev1.json" = {
        source = ../../files/${cfg.dashboards-dir}/node-exporter-full-rev1.json;
        group = "grafana";
        user = "grafana";
        mode = "0444";
      };
      "${cfg.dashboards-dir}/raid_mdadm_rev1.json" = {
        source = ../../files/${cfg.dashboards-dir}/raid_mdadm_rev1.json;
        group = "grafana";
        user = "grafana";
        mode = "0444";
      };
      "${cfg.dashboards-dir}/smartctl_exporter_rev1.json" = {
        source = ../../files/${cfg.dashboards-dir}/smartctl_exporter_rev1.json;
        group = "grafana";
        user = "grafana";
        mode = "0444";
      };
    };

    security.acme.certs = {
      ${cfg.grafana-domain} = lib.mkIf (
        config.services.grafana.enable &&
        config.services.nginx.virtualHosts."${cfg.grafana-domain}".enableACME
      ) {};
    };

    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            # Listening Address
            http_addr = cfg.inner-interface;
            # and Port
            http_port = grafana-listen-port;
            # Grafana needs to know on which domain and URL it's running
            domain = cfg.grafana-domain;
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
                  options.path = "/etc/${cfg.dashboards-dir}";
                }
              ];
            };
          };
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://${prometheus-full-path}";
            }
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://${loki-full-path}";
            }
          ];
        };
      };

      prometheus = lib.mkIf (config.services.grafana.enable) rec {
        enable = true;
        listenAddress = cfg.inner-interface;
        port = prometheus-listen-port;

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
            listenAddress = cfg.inner-interface;
          };
        };

        # ingest the published nodes
        scrapeConfigs = [
          {
            job_name = "nodes";
            static_configs = [{
              targets = [
                "${toString listenAddress}:${toString exporters.node.port}"
              ];
            }];
          }
          {
            job_name = "smartctl";
            static_configs = [{
              targets = [
                "${cfg.inner-interface}:${toString config.services.prometheus.exporters.smartctl.port}"
              ];
            }];
          }
        ];
      };

      loki = lib.mkIf (config.services.grafana.enable) {
        enable = true;
        configuration = {
          auth_enabled = false;
          analytics.reporting_enabled = false;
          server.http_listen_port = loki-listen-port;

          common = {
            instance_addr = cfg.inner-interface;
            path_prefix = "/tmp/loki";
            ring.kvstore.store = "inmemory";
          };

          ingester = {
            lifecycler = {
              address = cfg.inner-interface;
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
           volume_enabled = true;
          };


          table_manager = {
           retention_deletes_enabled = false;
           retention_period = "0s";
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

      promtail = lib.mkIf (config.services.loki.enable) {
        enable = true;
        configuration = {
          server = {
            http_listen_port = promtail-listen-port;
            grpc_listen_port = 0;
          };
          clients = [ { url = "http://${cfg.inner-interface}:${toString loki-listen-port}/loki/api/v1/push"; } ];
        };
      };

      nginx = lib.mkIf (config.services.grafana.enable) {
        enable = true;
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        # recommendedTlsSettings = true;

        upstreams = {
          "grafana" = {
            servers = {
              "${grafana-full-path}" = {};
            };
          };
#          "prometheus" = {
#            servers = {
#              "${prometheus-full-path}" = {};
#            };
#          };
        };

        virtualHosts."${cfg.grafana-domain}" = {
          forceSSL = true;
          enableACME = true;

          locations."/" = {
            proxyPass = "http://grafana";
            proxyWebsockets = true;
          };
          listen = [
            { addr = cfg.external-interface; port = 80; }
            { addr = cfg.external-interface; port = 443; ssl = true; }
          ];
        };

#        virtualHosts."${cfg.prometheus-domain}" = {
#          locations."/" = {
#            proxyPass = http://prometheus;
#            proxyWebsockets = true;
#          };
#          listen = [
#            { addr = cfg.external-interface; port = 80; }
#            { addr = cfg.external-interface; port = 443; ssl = true; }
#          ];
#        };

      };

    };
  };

}