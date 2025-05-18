{
  config,
  pkgs,
  lib,
  ...
}:
let
  nextcloud-dir = "nextcloud";
  nextcloud-domain = "nextcloud.nas.firefly.red";
in
{
  users.users.promtail.extraGroups = [ "nextcloud" ];

  monitoring.dashboards = lib.mkIf (config.services.nextcloud.enable) [
    {
      filename = "nextcloud_logs_rev1.json";
    }
  ];

  homepage.services.Services = {
    Nextcloud = lib.mkIf (config.services.nextcloud.enable) rec {
      description = "Open source content collaboration platform";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/nextcloud.svg";
      href = "https://nextcloud.nas.firefly.red/";
      siteMonitor = href;
    };
  };

  security.acme.certs = {
    ${nextcloud-domain} = lib.mkIf (config.services.nextcloud.enable) config.security.acme.defaults;
  };

  sops = lib.mkIf (config.services.nextcloud.enable) {
    secrets."nextcloud/admin-password".owner = "nextcloud";
    secrets."nextcloud/exporter-password".owner = "nextcloud-exporter";

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
      package = pkgs.nextcloud30;

      datadir = "/storage/${nextcloud-dir}";

      hostName = nextcloud-domain;
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
        adminpassFile = config.sops.secrets."nextcloud/admin-password".path;

        dbtype = "pgsql";
        dbhost = "localhost:5432";
        dbuser = "nextcloud";
        dbname = "nextcloud";
      };
    };

    postgresql = {
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          # TODO: WAIT FOR passwordFile option https://github.com/NixOS/nixpkgs/pull/326306
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    nginx.virtualHosts."${nextcloud-domain}" = lib.mkIf (config.services.nextcloud.enable) {
      forceSSL = true;
      enableACME = true;
      listen = [
        {
          addr = config.hosts.external-interface;
          port = 80;
        }
        {
          addr = config.hosts.external-interface;
          port = 443;
          ssl = true;
        }
      ];
    };

    promtail = lib.mkIf (config.services.nextcloud.enable) {
      configuration.scrape_configs = [
        {
          job_name = "system";
          static_configs = [
            {
              targets = [ "localhost" ];
              labels = {
                instance = nextcloud-domain;
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
          listenAddress = "localhost";
          tokenFile = config.sops.secrets."nextcloud/exporter-password".path;
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
                "localhost:${toString config.services.prometheus.exporters.nextcloud.port}"
              ];
            }
          ];
        }
      ];
    };
  };
}
