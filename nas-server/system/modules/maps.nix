{
  config,
  lib,
  ...
}:
let
  mantica-listen-port = 8093;
in
{
  hosts.entries = {
    mantica = lib.mkIf (config.services.mantica.enable) {
      domain = "maps.nas.firefly.red";
      local-port = mantica-listen-port;
    };
  };

  homepage.services.Services = {
    Mantica = lib.mkIf (config.services.mantica.enable) {
      description = "Self-hosted MBTiles/PMTiles atlas with MapLibre";
      icon = "https://upload.wikimedia.org/wikipedia/commons/b/b0/Openstreetmap_logo.svg";
      href = "https://maps.nas.firefly.red/";
      siteMonitor = "https://maps.nas.firefly.red/health";
    };
  };

  sops.secrets = {
    "mantica/username" = lib.mkIf config.services.mantica.enable {
      owner = config.services.mantica.user;
      restartUnits = [ "mantica.service" ];
    };
    "mantica/password" = lib.mkIf config.services.mantica.enable {
      owner = config.services.mantica.user;
      restartUnits = [ "mantica.service" ];
    };
  };

  services.mantica = {
    port = mantica-listen-port;
    tilesDir = "/storage/mantica/tilesets";
    authUserFile = config.sops.secrets."mantica/username".path;
    authPassFile = config.sops.secrets."mantica/password".path;
    # After `sops nix-secrets/nas.yaml` add:
    #   mantica:
    #     geocoder-keys: "{}"
    # and wire:
    #   sops.secrets."mantica/geocoder-keys" = { owner = ...; restartUnits = [ "mantica.service" ]; };
    #   geocoderKeysFile = config.sops.secrets."mantica/geocoder-keys".path;
  };
}
