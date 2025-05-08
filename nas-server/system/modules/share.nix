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
  acme.upstreams =
    [ ]
    ++ lib.optional (config.services.athens.enable) {
      name = "athens";
      domain = "athens.nas.firefly.red";
      local-port = athens-listen-port;
    }
    ++ lib.optional (config.services.ncps.enable) {
      name = "ncps";
      domain = "ncps.nas.firefly.red";
      local-port = ncps-listen-port;
    };

  homepage.services.Development = {
    Athens = lib.mkIf (config.services.athens.enable) rec {
      description = "A Go module datastore and proxy";
      icon = "https://www.svgrepo.com/download/215353/parthenon-athens.svg";
      href = "https://athens.nas.firefly.red/";
      siteMonitor = href;
    };
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
        hostName = config.networking.hostName;
        databaseURL = "sqlite:/storage/ncps/db.sqlite";
      };
    };

  };
}
