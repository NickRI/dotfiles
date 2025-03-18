{
  pkgs,
  sops-secrets,
  ...
}:
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
    programs = {
      thunderbird = {
        enable = true;
        settings = {
          "font.language.group" = "x-cyrillic";
          "intl.accept_languages" = "ru-RU, ru, en-US, en";
          "intl.locale.requested" = "ru,en-US";
        };
        package = pkgs.thunderbird.override {
          extraPolicies.ExtensionSettings = {
            "langpack-ru@thunderbird.mozilla.org" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.thunderbird.net/thunderbird/downloads/file/1037160/russian_ru_language_pack-137.0.20250311.191724-tb.xpi?src=";
            };
            "mas@aandrzej.com" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.thunderbird.net/thunderbird/downloads/file/1030065/minimize_on_startup-1.1-tb.xpi?src=";
            };
            "minimizeonclose@rsjtdrjgfuzkfg.com" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.thunderbird.net/thunderbird/downloads/file/1030066/minimize_on_close-2.0.1.4-tb.xpi?src=";
            };
          };
        };
        profiles = {
          default = {
            isDefault = true;
            settings = {
              "extensions.autoDisableScopes" = 0;
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
          flavor = "gmail.com";
        };
        "${accounts.secondary}" = {
          thunderbird = thunderbird-setup;
          address = accounts.secondary;
          realName = "Nick Noname";
          flavor = "yandex.com";
        };
        "${accounts.business}" = {
          thunderbird = thunderbird-setup;
          address = accounts.business;
          realName = "ITWorks";
          flavor = "gmail.com";
        };
        "${accounts.work}" = {
          thunderbird = thunderbird-setup;
          address = accounts.work;
          realName = "Nick";
          flavor = "gmail.com";
        };
      };
    };
  };
}
