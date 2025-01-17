{config, lib, ...}:

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
        credentialsFile = config.sops.secrets.cloudflare-env.path;
      };
    };

  };
}