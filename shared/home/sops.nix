{
  config,
  sops-secrets,
  sops-file ? "secrets.yaml",
  ...
}:

{
  config = {
    sops = {
      defaultSopsFile = "${toString sops-secrets}/${sops-file}";
      defaultSopsFormat = "yaml";
      age = {
        keyFile = "${config.home.homeDirectory}/.sops/age/keys.txt";
        generateKey = true;
      };
    };
  };
}
