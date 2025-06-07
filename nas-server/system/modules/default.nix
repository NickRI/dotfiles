{ ... }:

{
  imports = [
    ./database.nix
    ./acme.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./download.nix
    ./development.nix
    ./share.nix
    ./sync.nix
    ./homepage.nix
    ./misc.nix
  ];

  config.services = {
    postgresql.enable = true;
    nginx.enable = true;
    grafana.enable = true;
    scrutiny.enable = true;
    nextcloud.enable = true;
    gitea.enable = true;
    transmission.enable = true;
    bitmagnet.enable = false;
    homepage-dashboard.enable = true;
    athens.enable = true;
    ncps.enable = true;
    microbin.enable = true;
    kavita.enable = true;
    immich.enable = true;
  };
}
