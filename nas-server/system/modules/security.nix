{
  config,
  lib,
  ...
}:
let
  vaultwarden-listen-port = 8222;
  vaultwarden-domain = "vault.nas.firefly.red";
  vaultwarden-data = "/storage/vaultwarden";
in
{
  hosts.entries = {
    vaultwarden = lib.mkIf (config.services.vaultwarden.enable) {
      domain = vaultwarden-domain;
      local-port = vaultwarden-listen-port;
    };
  };

  homepage.services.Services = {
    Vaultwarden = lib.mkIf (config.services.vaultwarden.enable) rec {
      description = "Unofficial Bitwarden compatible server";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/vaultwarden.svg";
      href = "https://${vaultwarden-domain}/";
      siteMonitor = href;
    };
  };

  sops = lib.mkIf (config.services.vaultwarden.enable) {
    secrets = {
      "smtp/login" = { };
      "smtp/password" = { };
      "vaultwarden/admin-token" = { };
    };

    templates."vaultwarden.env" = {
      owner = "vaultwarden";
      content = ''
        ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/admin-token"}
        SMTP_USERNAME=${config.sops.placeholder."smtp/login"}
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
      '';
    };
  };

  systemd = lib.mkIf (config.services.vaultwarden.enable) {
    tmpfiles.rules = [
      "d ${vaultwarden-data} 0700 vaultwarden vaultwarden -"
    ];
    services.vaultwarden.serviceConfig.ReadWritePaths = [ vaultwarden-data ];
  };

  services.vaultwarden = {
    dbBackend = "postgresql";
    configurePostgres = true;
    domain = vaultwarden-domain;
    environmentFile = config.sops.templates."vaultwarden.env".path;
    config = {
      DATA_FOLDER = vaultwarden-data;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = vaultwarden-listen-port;
      ENABLE_WEBSOCKET = true;
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = true;
      SMTP_HOST = "smtp.mailersend.net";
      SMTP_FROM = "no-reply@firefly.red";
      SMTP_FROM_NAME = "Vaultwarden";
      SMTP_SECURITY = "starttls";
      SMTP_PORT = 587;
    };
  };
}
