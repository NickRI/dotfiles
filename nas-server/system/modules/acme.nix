{ config, ... }:

{
  config = {

    sops.secrets.cloudflare-env.owner = "acme";

    security.acme = {
      acceptTerms = true;

      defaults = {
        group = "nginx";
        email = "admin@firefly.red";
        dnsProvider = "cloudflare";
        webroot = null;
        environmentFile = config.sops.secrets.cloudflare-env.path;
      };
    };

  };
}
