{ config, lib, ... }:

{
  sops = lib.mkIf (config.services.syncthing.enable) {
    secrets."syncthing/work-laptop" = {
      owner = config.services.syncthing.user;
      mode = "0644";
    };
  };

  services.syncthing = {
    enable = true;
    tray.enable = true;
    key = config.sops.secrets."syncthing/work-laptop".path;
  };
}
