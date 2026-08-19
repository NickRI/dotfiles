{
  config,
  lib,
  pkgs,
  ...
}:
let
  transmission-listen-port = 5055;
  bitmagnet-listen-port = 3333;
  hfdownloader-listen-port = 8090;
in
{
  imports = [
    ../../../shared/tools/hfdownloader.nix
  ];

  hosts.entries = {
    transmission = lib.mkIf (config.services.transmission.enable) {
      domain = "transmission.nas.firefly.red";
      local-port = transmission-listen-port;
    };
    bitmagnet = lib.mkIf (config.services.bitmagnet.enable) {
      domain = "bitmagnet.nas.firefly.red";
      local-port = bitmagnet-listen-port;
    };
    hfdownloader = lib.mkIf (config.services.hfdownloader.enable) {
      domain = "hf.nas.firefly.red";
      local-port = hfdownloader-listen-port;
    };
  };

  homepage.services.Downloads = {
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
    HuggingFace = lib.mkIf (config.services.hfdownloader.enable) rec {
      description = "Fast, resumable downloader for Hugging Face models and datasets";
      icon = "https://huggingface.co/front/assets/huggingface_logo-noborder.svg";
      href = "https://hf.nas.firefly.red/";
      siteMonitor = href;
    };
  };

  sops = {
    secrets = {
      "transmission/username" = { };
      "transmission/password" = { };
      "hfdownloader/username" = lib.mkIf config.services.hfdownloader.enable {
        owner = config.services.hfdownloader.user;
        restartUnits = [ "hfdownloader.service" ];
      };
      "hfdownloader/password" = lib.mkIf config.services.hfdownloader.enable {
        owner = config.services.hfdownloader.user;
        restartUnits = [ "hfdownloader.service" ];
      };
      "hfdownloader/token" = lib.mkIf config.services.hfdownloader.enable {
        owner = config.services.hfdownloader.user;
        restartUnits = [ "hfdownloader.service" ];
      };
    };

    templates."transmission.json" = {
      mode = "0644";
      content = ''
        {
          "rpc-authentication-required": true,
          "rpc-username": "${config.sops.placeholder."transmission/username"}",
          "rpc-password": "${config.sops.placeholder."transmission/password"}"
        }'';
    };
  };

  services = {
    transmission = {
      package = pkgs.transmission_4;
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
          host = "localhost";
          name = "bitmagnet";
          user = "bitmagnet";
        };
      };

      useLocalPostgresDB = false;
    };

    hfdownloader = {
      port = hfdownloader-listen-port;
      cacheDir = "/storage/huggingface";
      tokenFile = config.sops.secrets."hfdownloader/token".path;
      authUserFile = config.sops.secrets."hfdownloader/username".path;
      authPassFile = config.sops.secrets."hfdownloader/password".path;
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
