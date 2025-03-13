{ config, sops-secrets, ... }:
let
  accounts = builtins.fromJSON (builtins.readFile "${toString sops-secrets}/accounts.json");
in
{
  config = {
    sops.secrets = {
      "accounts-passwords/primary" = { };
      "accounts-passwords/secondary" = { };
      "accounts-passwords/business" = { };
      "accounts-passwords/work" = { };
    };

    accounts = {
      email.accounts = {
        primary = {
          name = "primary";
          primary = true;
          address = accounts.primary;
          realName = "Nick Noname";
          passwordCommand = "cat ${config.sops.secrets."accounts-passwords/primary".path}";
          flavor = "gmail.com";
        };
        secondary = {
          name = "secondary";
          address = accounts.secondary;
          realName = "Nick Noname";
          passwordCommand = "cat ${config.sops.secrets."accounts-passwords/secondary".path}";
          flavor = "yandex.com";
        };
        business = {
          name = "business";
          address = accounts.business;
          realName = "ITWorks";
          passwordCommand = "cat ${config.sops.secrets."accounts-passwords/businessry".path}";
          flavor = "gmail.com";
        };
        work = {
          name = "work";
          address = accounts.work;
          realName = "Nick";
          passwordCommand = "cat ${config.sops.secrets."accounts-passwords/work".path}";
          flavor = "gmail.com";
        };
      };
    };
  };
}
