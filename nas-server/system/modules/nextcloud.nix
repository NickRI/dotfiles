{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = builtins.fromJSON (builtins.readFile ./config.json);

  nextcloud-dir = "nextcloud";
in
{
  config = {
    users.users.promtail.extraGroups = [ "nextcloud" ];

    environment.etc = lib.mkIf (config.services.grafana.enable && config.services.nextcloud.enable) {
      "${cfg.dashboards-dir}/nextcloud_logs_rev1.json" = {
        source = ../../files/${cfg.dashboards-dir}/nextcloud_logs_rev1.json;
        group = "grafana";
        user = "grafana";
        mode = "0444";
      };
    };

    security.acme.certs = {
      ${cfg.nextcloud-domain} = lib.mkIf (
        config.services.nextcloud.enable
        && config.services.nginx.virtualHosts."${cfg.nextcloud-domain}".enableACME
      ) config.security.acme.defaults;
    };

    sops = lib.mkIf (config.services.nextcloud.enable) {
      secrets."nas/nextcloud/admin-password".owner = "nextcloud";
      secrets."nas/nextcloud/exporter-password".owner = "nextcloud-exporter";

      secrets = {
        "smtp/login" = { };
        "smtp/password" = { };
      };

      templates."smtp.json" = {
        mode = "0644";
        owner = "nextcloud";
        content = ''
          {
                    "mail_smtpname": "${config.sops.placeholder."smtp/login"}",
                    "mail_smtppassword": "${config.sops.placeholder."smtp/password"}"
                  }'';
      };
    };

    systemd = {
      services.nextcloud-generate-preview = {
        serviceConfig = {
          ExecStart = "${pkgs.writeScript "nextcloud-generate-preview.sh" ''
            #!/bin/sh
            /run/current-system/sw/bin/nextcloud-occ preview:pre-generate -vvv
          ''}";
          User = "nextcloud";
          Group = "nextcloud";
        };
        description = "nextcloud generate preview";
        startAt = "hourly";
      };
    };

    environment.systemPackages = with pkgs; [
      ghostscript # needed for generate preview for pdfs
    ];

    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud30;

        datadir = "/storage/${nextcloud-dir}";

        hostName = cfg.nextcloud-domain;
        https = true;

        database.createLocally = true;
        configureRedis = true;

        settings = {
          loglevel = 1;
          log_type = "file";

          trashbin_retention_obligation = "disabled";
          default_phone_region = "ES";
          maintenance_window_start = 5;

          mail_sendmailmode = "smtp";
          mail_from_address = "no-reply";
          mail_domain = "firefly.red";
          mail_smtpmode = "smtp";
          mail_smtptimeout = 5;
          mail_smtpsecure = "";
          mail_smtpauth = 1;
          mail_smtphost = "smtp.mailersend.net";
          mail_smtpport = "587";

          enable_previews = true;
          enabledPreviewProviders = [
            "OC\\Preview\\TXT"
            "OC\\Preview\\MarkDown"
            "OC\\Preview\\OpenDocument"
            "OC\\Preview\\PDF"
            "OC\\Preview\\MSOffice2003"
            "OC\\Preview\\MSOfficeDoc"
            "OC\\Preview\\Image"
            "OC\\Preview\\Photoshop"
            "OC\\Preview\\TIFF"
            "OC\\Preview\\SVG"
            "OC\\Preview\\Font"
            "OC\\Preview\\MP3"
            "OC\\Preview\\Movie"
            "OC\\Preview\\MKV"
            "OC\\Preview\\MP4"
            "OC\\Preview\\AVI"
          ];
        };

        phpOptions = {
          "opcache.interned_strings_buffer" = 16;
          memory_limit = lib.mkDefault "2G";
          max_execution_time = 600;
          max_input_time = 600;
          default_socket_timeout = 360;
          post_max_size = "512M";
          upload_max_filesize = "512M";
        };

        fastcgiTimeout = 240;

        secretFile = config.sops.templates."smtp.json".path;

        extraAppsEnable = true;
        autoUpdateApps.enable = true;
        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit
            onlyoffice
            maps
            memories
            contacts
            calendar
            phonetrack
            previewgenerator
            unsplash
            ;
          duplicatefinder = pkgs.fetchNextcloudApp {
            url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.6.0/duplicatefinder-v1.6.0.tar.gz";
            hash = "sha256-J+P+9Ajz998ua1RRwuj1h4WOOl0WODu3uVJNGosbObI=";
            license = "agpl3Only";
          };
          twofactor_totp = pkgs.fetchNextcloudApp {
            url = "https://github.com/nextcloud/twofactor_totp/archive/refs/tags/v30.0.4.tar.gz";
            hash = "sha256-WydCFsIUlHSSTkrwRZ6z33dl952nDauv16Va2wdisMs=";
            license = "agpl3Only";
          };
        };

        config = {
          adminuser = "nikolai";
          adminpassFile = config.sops.secrets."nas/nextcloud/admin-password".path;

          dbtype = "sqlite";
        };
      };

      nginx = lib.mkIf (config.services.nextcloud.enable) {
        enable = true;
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;

        virtualHosts."${cfg.nextcloud-domain}" = {
          forceSSL = true;
          enableACME = true;
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

      promtail = lib.mkIf (config.services.nextcloud.enable) {
        configuration.scrape_configs = [
          {
            job_name = "system";
            static_configs = [
              {
                targets = [ "localhost" ];
                labels = {
                  instance = cfg.nextcloud-domain;
                  env = "${config.networking.hostName}";
                  job = "nextcloud";
                  __path__ = "/storage/${nextcloud-dir}/data/{nextcloud,audit}.log";
                };
              }
            ];
          }
        ];
      };

      prometheus = lib.mkIf (config.services.nextcloud.enable) {
        exporters = {
          nextcloud = {
            enable = true;
            listenAddress = cfg.inner-interface;
            tokenFile = config.sops.secrets."nas/nextcloud/exporter-password".path;
            url = "https://${config.services.nextcloud.hostName}";
            timeout = "60s";
            extraFlags = [
              "--tls-skip-verify true"
            ];
          };
        };
        scrapeConfigs = [
          {
            job_name = "nextcloud";
            static_configs = [
              {
                targets = [
                  "${cfg.inner-interface}:${toString config.services.prometheus.exporters.nextcloud.port}"
                ];
              }
            ];
          }
        ];
      };

    };
  };
}
