{
  config,
  lib,
  pkgs,
  ...
}:
let
  kavita-listen-port = 8283;
  immich-listen-port = 2283;
in
{
  hosts.entries = {
    kavita = lib.mkIf (config.services.kavita.enable) {
      domain = "kavita.nas.firefly.red";
      local-port = kavita-listen-port;
    };
    immich = lib.mkIf (config.services.immich.enable) {
      domain = "immich.nas.firefly.red";
      local-port = immich-listen-port;
      location-extra-config = "
        client_max_body_size 0;
      ";
    };
  };

  homepage.services.Services = {
    Kavita = lib.mkIf (config.services.kavita.enable) rec {
      description = "Kavita is a fast, feature rich, cross platform reading server.";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/kavita.svg";
      href = "https://kavita.nas.firefly.red/";
      siteMonitor = href;
    };
    Immich = lib.mkIf (config.services.immich.enable) rec {
      description = "Self-hosted photo and video management solution";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/immich.svg";
      href = "https://immich.nas.firefly.red/";
      siteMonitor = href;
    };
  };

  sops = {
    secrets.kavita-token.owner = lib.mkIf (config.services.kavita.enable) config.services.kavita.user;

    secrets = {
      "immich/db-password".owner = lib.mkIf (config.services.immich.enable) config.services.immich.user;
    };

    templates.secretsFile = {
      mode = "0644";
      owner = config.services.immich.user;
      content = ''
        DB_PASSWORD="${config.sops.placeholder."immich/db-password"}",
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    immich-go
  ];

  services = {
    kavita = {
      settings = {
        IpAddresses = "127.0.0.1";
        Port = kavita-listen-port;
      };
      dataDir = "/storage/kavita";
      tokenKeyFile = config.sops.secrets.kavita-token.path;
    };

    immich = {
      port = immich-listen-port;
      host = "127.0.0.1";
      mediaLocation = "/storage/immich";
      secretsFile = config.sops.templates.secretsFile.path;
      database = {
        createDB = false;
        enable = true;
        user = "immich";
        name = "immich";
        host = "localhost";
        port = 5432;
      };
    };

    postgresql = {
      ensureDatabases = [ "immich" ];
      ensureUsers = [
        {
          # TODO: WAIT FOR passwordFile option https://github.com/NixOS/nixpkgs/pull/326306
          name = "immich";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
