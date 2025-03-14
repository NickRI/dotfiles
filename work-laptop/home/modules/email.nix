{ config, sops-secrets, ... }:
let
  accounts = builtins.fromJSON (builtins.readFile "${toString sops-secrets}/accounts.json");

  thunderbird-setup = {
    enable = true;
    profiles = [ "default" ];
    settings = id: {
      "mail.smtpserver.smtp_${id}.authMethod" = 10;
      "mail.server.server_${id}.authMethod" = 10;
    };
  };
in
{
  config = {
    sops.secrets = {
      "accounts-passwords/primary" = { };
      "accounts-passwords/secondary" = { };
      "accounts-passwords/business" = { };
      "accounts-passwords/work" = { };
    };

    programs = {
      thunderbird = {
        enable = true;
        profiles = {
          default = {
            isDefault = true;
            settings = {
              "font.language.group" = "x-cyrillic";
              "intl.accept_languages" = "ru-RU, ru, en-US, en";
              "intl.locale.requested" = "ru,en-US";
            };
          };
        };
      };
    };

    accounts = {
      email.accounts = {
        "${accounts.primary}" = {
          primary = true;
          thunderbird = thunderbird-setup;
          address = accounts.primary;
          realName = "Nick Noname";
          passwordCommand = [ "cat ${config.sops.secrets."accounts-passwords/primary".path}" ];
          flavor = "gmail.com";
        };
        "${accounts.secondary}" = {
          thunderbird = thunderbird-setup;
          address = accounts.secondary;
          realName = "Nick Noname";
          passwordCommand = [ "cat ${config.sops.secrets."accounts-passwords/secondary".path}" ];
          flavor = "yandex.com";
        };
        "${accounts.business}" = {
          thunderbird = thunderbird-setup;
          address = accounts.business;
          realName = "ITWorks";
          passwordCommand = [ "cat ${config.sops.secrets."accounts-passwords/business".path}" ];
          flavor = "gmail.com";
        };
        "${accounts.work}" = {
          thunderbird = thunderbird-setup;
          address = accounts.work;
          realName = "Nick";
          passwordCommand = [ "cat ${config.sops.secrets."accounts-passwords/work".path}" ];
          flavor = "gmail.com";
        };
      };

      contact = {
        basePath = ".accounts/contacts";
        accounts = {
          primary = {
            name = accounts.primary;
            remote = {
              userName = accounts.primary;
              passwordCommand = [ "cat ${config.sops.secrets."accounts-passwords/primary".path}" ];
              type = "google_contacts";
            };
          };
        };
      };
    };
  };
}
