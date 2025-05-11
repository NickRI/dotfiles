{
  config,
  lib,
  pkgs,
  ...
}:
let
  transmission-listen-port = 5055;
  bitmagnet-listen-port = 3333;
in
{
  hosts.entries = {
    transmission = lib.mkIf (config.services.transmission.enable) {
      domain = "transmission.nas.firefly.red";
      local-port = transmission-listen-port;
    };
    bitmagnet = lib.mkIf (config.services.bitmagnet.enable) {
      domain = "bitmagnet.nas.firefly.red";
      local-port = bitmagnet-listen-port;
    };
  };

  homepage.services.Services = {
    Transmission = lib.mkIf (config.services.transmission.enable) rec {
      description = "A fast, easy and free Bittorrent client for macOS, Windows and Linux";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/transmission.svg";
      href = "https://transmission.nas.firefly.red/";
      siteMonitor = href;
    };
    Bitmagnet = lib.mkIf (config.services.bitmagnet.enable) rec {
      description = "A self-hosted BitTorrent indexer, DHT crawler";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/bitmagnet.png";
      href = "https://bitmagnet.nas.firefly.red/";
      siteMonitor = href;
    };
  };

  sops = {
    secrets = {
      "nas/transmission/username" = { };
      "nas/transmission/password" = { };
    };

    templates."transmission.json" = {
      mode = "0644";
      content = ''
        {
          "rpc-authentication-required": true,
          "rpc-username": "${config.sops.placeholder."nas/transmission/username"}",
          "rpc-password": "${config.sops.placeholder."nas/transmission/password"}"
        }'';
    };
  };

  services = {
    transmission = {
      webHome = pkgs.flood-for-transmission;

      credentialsFile = config.sops.templates."transmission.json".path;

      settings = {
        watch-dir = "/storage/transmission/watch";
        download-dir = "/storage/transmission/downloads";
        incomplete-dir = "/storage/transmission/incomplete";

        rpc-enabled = true;
        rpc-bind-address = "localhost";
        rpc-port = transmission-listen-port;
        rpc-host-whitelist = "*";
      };
    };

    bitmagnet = {
      settings = {
        tmdb.enabled = false;
        http_server.port = ":${toString bitmagnet-listen-port}";
        postgres = {
          host = "localhost:5432";
          name = "bitmagnet";
          user = "bitmagnet";
        };
      };

      useLocalPostgresDB = false;
    };

    postgresql = {
      ensureDatabases = [ "bitmagnet" ];
      ensureUsers = [
        {
          # TODO: WAIT FOR passwordFile option https://github.com/NixOS/nixpkgs/pull/326306
          name = "bitmagnet";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
