{ config, sops-secrets, ... }:

{
  config = {
    sops = {
      defaultSopsFile = "${toString sops-secrets}/secrets.yaml";
      defaultSopsFormat = "yaml";
      age = {
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        generateKey = true;
      };
    };
  };
}
