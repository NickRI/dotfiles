{
  pkgs,
  config,
  lib,
  ...
}:

let
  athens-listen-port = 6934;
  ncps-listen-port = 8501;
  microbin-listen-port = 8521;
  registry-listen-port = 5003;
  registry-domain = "registry.firefly.red";
  registry-ui-listen-port = 5004;
in

{
  imports = [
    ../../../shared/tools/docker-registry-ui.nix
  ];

  hosts.entries = {
    athens = lib.mkIf (config.services.athens.enable) {
      domain = "athens.nas.firefly.red";
      local-port = athens-listen-port;
    };
    microbin = lib.mkIf (config.services.microbin.enable) {
      domain = "microbin.nas.firefly.red";
      local-port = microbin-listen-port;
    };
    ncps = lib.mkIf (config.services.ncps.enable) {
      domain = "ncps.nas.firefly.red";
      local-port = ncps-listen-port;
      location-extra-config = "
        proxy_connect_timeout 1m;
        proxy_read_timeout 7m;
        proxy_send_timeout 1m;
      ";
    };
    registry = lib.mkIf (config.services.dockerRegistry.enable) {
      domain = registry-domain;
      local-port = registry-ui-listen-port;
      locations = {
        "/v2/" = {
          proxyPass = "http://127.0.0.1:${toString registry-listen-port}";
          extraConfig = ''
            proxy_pass_header Location;
            add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;

            chunked_transfer_encoding on;
            client_max_body_size 0;
          '';
        };
      };
    };
  };

  homepage.services = {
    Development = {
      Athens = lib.mkIf (config.services.athens.enable) rec {
        description = "A Go module datastore and proxy";
        icon = "https://docs.gomods.io/logo@2x.png";
        href = "https://athens.nas.firefly.red/";
        siteMonitor = href;
      };
      Registry = lib.mkIf (config.services.dockerRegistry.enable) rec {
        description = "The toolkit to pack, ship, store, and deliver container content";
        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/container-hub.svg";
        href = "https://${registry-domain}/";
        siteMonitor = href;
      };
    };
    Downloads = {
      Microbin = lib.mkIf (config.services.microbin.enable) rec {
        description = "A secure, configurable file-sharing and URL shortening web app written in Rust";
        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/microbin.svg";
        href = "https://microbin.nas.firefly.red/";
        siteMonitor = href;
      };
    };
  };

  sops.secrets = lib.mkIf (config.services.ncps.enable) {
    "ncps/secretKeyFile".owner = "ncps";
  };

  systemd.services.athens = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };

  systemd.services.docker-registry.environment = {
    OTEL_TRACES_EXPORTER = "none";
  };

  services = {
    samba = {
      enable = config.services.transmission.enable;
      openFirewall = true;

      settings = {
        downloads = {
          path = "/storage/transmission/downloads";
          browseable = "yes";
          writable = "no";
          public = "yes";
        };
        uploads = {
          path = "/storage/uploads";
          browseable = "yes";
          writable = "yes";
          public = "yes";
          "force user" = "nas";
          "force group" = "users";
          "create mask" = "0666";
          "directory mask" = "0777";
        };
      };
    };

    athens = {
      enable = true;
      storage.disk.rootPath = "/storage/athens";
      port = athens-listen-port;
      logLevel = "info";
      indexType = "postgres";
      index.postgres = {
        user = "athens";
        database = "athens";
        host = "localhost";
        params = {
          connect_timeout = "30";
          sslmode = "disable";
        };
      };
    };

    postgresql = {
      ensureDatabases = [ "athens" ];
      ensureUsers = [
        {
          # TODO: WAIT FOR passwordFile option https://github.com/NixOS/nixpkgs/pull/326306
          name = "athens";
          ensureDBOwnership = true;
        }
      ];
    };

    ncps = {
      logLevel = "trace";
      server.addr = "localhost:${toString ncps-listen-port}";
      upstream = {
        caches = [ "https://cache.nixos.org" ];
        publicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      };
      cache = {
        maxSize = "200G";
        lru.schedule = "0 2 * * *";
        dataPath = "/storage/ncps/cache";
        secretKeyPath = config.sops.secrets."ncps/secretKeyFile".path;
        hostName = config.networking.hostName;
        databaseURL = "sqlite:/storage/ncps/db.sqlite";
      };
    };

    microbin = {
      dataDir = "/storage/microbin";
      settings = {
        MICROBIN_PORT = microbin-listen-port;
        MICROBIN_BIND = "127.0.0.1";
        MICROBIN_ENCRYPTION_CLIENT_SIDE = true;
        MICROBIN_ENCRYPTION_SERVER_SIDE = true;
        MICROBIN_ENABLE_READONLY = true;
      };
    };

    dockerRegistry = {
      port = registry-listen-port;
      enableDelete = true;
      enableGarbageCollect = true;
      openFirewall = true;
      extraConfig = {
        http.relativeurls = true;
        http.host = "https://${registry-domain}/";
      };
      storagePath = "/storage/registry";
    };

    docker-registry-ui = {
      enable = config.services.dockerRegistry.enable;
      path = "${config.services.dockerRegistry.storagePath}/ui";
      port = registry-ui-listen-port;
      registries = [
        {
          name = "Firefly Registry";
          api = "https://${registry-domain}";
          default = true;
          bulkOperationsEnabled = true;
          vulnerabilityScan = {
            enabled = true;
            scanner = "trivy";
            scannerUrl = "";
            autoScanRules = [ ];
            scanLatestOnly = 1;
          };
        }
      ];
    };
  };
}
