{
  config,
  pkgs,
  lib,
  ...
}:

let
  athens-listen-port = 6934;
  ncps-listen-port = 8501;
  microbin-listen-port = 8521;
in

{
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
  };

  homepage.services = {
    Development = {
      Athens = lib.mkIf (config.services.athens.enable) rec {
        description = "A Go module datastore and proxy";
        icon = "https://www.svgrepo.com/download/215353/parthenon-athens.svg";
        href = "https://athens.nas.firefly.red/";
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

  services = {
    samba = {
      enable = config.services.transmission.enable;
      openFirewall = true;

      settings = {
        downloads = {
          path = "/storage/transmission/downloads";
          browseable = "yes";
          writeable = "no";
          public = "yes";
        };
        uploads = {
          path = "/storage/uploads";
          browseable = "yes";
          writeable = "yes";
          public = "yes";
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
      package = pkgs.unstable.ncps;
      logLevel = "trace";
      server.addr = "localhost:${toString ncps-listen-port}";
      upstream = {
        caches = [ "https://cache.nixos.org" ];
        publicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      };
      cache = {
        maxSize = "100G";
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
  };
}
