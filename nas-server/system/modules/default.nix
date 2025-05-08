{ ... }:

{
  imports = [
    ./acme.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./download.nix
    ./development.nix
    ./share.nix
    ./homepage.nix
  ];

  config.services = {
    nginx.enable = true;
    grafana.enable = true;
    scrutiny.enable = true;
    nextcloud.enable = true;
    gitea.enable = true;
    transmission.enable = true;
    bitmagnet.enable = true;
    homepage-dashboard.enable = true;
    athens.enable = true;
    ncps.enable = true;
  };
}
