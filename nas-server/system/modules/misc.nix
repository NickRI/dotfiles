{
  config,
  lib,
  pkgs,
  ...
}:
let
  kavita-listen-port = 8283;
  immich-listen-port = 2283;
  zimi-listen-port = 8899;
in
{
  imports = [
    ../../../shared/tools/zimi.nix
  ];

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
    zimi = lib.mkIf (config.services.zimi.enable) {
      domain = "zimi.nas.firefly.red";
      local-port = zimi-listen-port;
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
    Zimi = lib.mkIf (config.services.zimi.enable) rec {
      description = "Offline internet for ZIM files — searchable library with auto-updates";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/kiwix.svg";
      href = "https://zimi.nas.firefly.red/";
      siteMonitor = href;
    };
  };

  sops = {
    secrets.kavita-token.owner = lib.mkIf (config.services.kavita.enable) config.services.kavita.user;

    secrets = {
      "smtp/login" = { };
      "smtp/password" = { };
      "immich/db-password".owner = lib.mkIf (config.services.immich.enable) config.services.immich.user;
      "zimi/manage-password" = lib.mkIf (config.services.zimi.enable) {
        owner = config.services.zimi.user;
        restartUnits = [ "zimi.service" ];
      };
    };

    templates.secretsFile = {
      mode = "0644";
      owner = config.services.immich.user;
      content = ''
        DB_PASSWORD="${config.sops.placeholder."immich/db-password"}",
      '';
    };
  };

  # Kavita stores SMTP in SQLite (ServerSetting), not appsettings.json.
  # https://wiki.kavitareader.com/guides/admin-settings/email/
  systemd.services.kavita = lib.mkIf (config.services.kavita.enable) {
    path = [ pkgs.sqlite ];
    serviceConfig.LoadCredential = lib.mkForce [
      "token:${config.services.kavita.tokenKeyFile}"
      "smtp-login:${config.sops.secrets."smtp/login".path}"
      "smtp-password:${config.sops.secrets."smtp/password".path}"
    ];
    preStart = lib.mkAfter ''
      templates="${config.services.kavita.package.backend}/lib/kavita-backend/EmailTemplates"
      dest="${config.services.kavita.dataDir}/EmailTemplates"
      [ -d "$templates" ]
      if [ -d "$dest" ] && [ ! -L "$dest" ]; then
        rmdir "$dest"
      fi
      ln -sfn "$templates" "$dest"

      db="${config.services.kavita.dataDir}/config/kavita.db"
      [ -f "$db" ] || exit 0

      table=$(sqlite3 "$db" "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('ServerSetting', 'ServerSettings')")
      set_setting() {
        key="$1"
        expr="$2"
        updated=$(sqlite3 "$db" "UPDATE $table SET Value = $expr WHERE Key = $key; SELECT changes();")
        [ "$updated" = 1 ]
      }

      set_setting 20 "'https://${config.hosts.entries.kavita.domain}'"
      set_setting 28 "'no-reply@firefly.red'"
      set_setting 29 "'Kavita'"
      set_setting 30 "rtrim(readfile('$CREDENTIALS_DIRECTORY/smtp-login'), char(10, 13))"
      set_setting 31 "rtrim(readfile('$CREDENTIALS_DIRECTORY/smtp-password'), char(10, 13))"
      set_setting 32 "'smtp.mailersend.net'"
      set_setting 33 "'587'"
      set_setting 34 "'true'"
    '';
  };

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
      package = pkgs.unstable.immich;
      host = "127.0.0.1";
      mediaLocation = "/storage/immich/media";
      machine-learning.environment = {
        MACHINE_LEARNING_CACHE_FOLDER = lib.mkForce "/storage/immich/cache";
        MPLCONFIGDIR = lib.mkForce "/storage/immich/matplot";
      };
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

    zimi = {
      port = zimi-listen-port;
      zimDir = "/storage/zimi/zims";
      dataDir = "/storage/zimi/config";
      managePasswordFile = config.sops.secrets."zimi/manage-password".path;
      publicAccess = "private";
      bitTorrent.enable = false;
      maxConcurrentDownloads = 6;
      autoUpdate = true;
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
