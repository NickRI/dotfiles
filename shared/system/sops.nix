{
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
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
    };
  };
}
