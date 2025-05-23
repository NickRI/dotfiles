{
  config,
  pkgs,
  lib,
  ...
}:

let
  athens-listen-port = 6934;
  ncps-listen-port = 8501;
in

{
  hosts.entries = {
    athens = lib.mkIf (config.services.athens.enable) {
      domain = "athens.nas.firefly.red";
      local-port = athens-listen-port;
    };
    ncps = lib.mkIf (config.services.ncps.enable) {
      domain = "ncps.nas.firefly.red";
      local-port = ncps-listen-port;
      location-extra-config = "
        proxy_connect_timeout 1m;
        proxy_read_timeout 5m;
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
  };
}
