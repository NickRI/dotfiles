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
  acme.upstreams =
    [ ]
    ++ lib.optional (config.services.transmission.enable) {
      name = "transmission";
      domain = "transmission.nas.firefly.red";
      local-port = transmission-listen-port;
    }
    ++ lib.optional (config.services.bitmagnet.enable) {
      name = "bitmagnet";
      domain = "bitmagnet.nas.firefly.red";
      local-port = bitmagnet-listen-port;
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
      };
    };
  };
}
