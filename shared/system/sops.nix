{ config, sops-secrets, ... }:

{
  config = {
    sops = {
      defaultSopsFile = "${toString sops-secrets}/secrets.yaml";
      defaultSopsFormat = "yaml";
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
    };
  };
}
