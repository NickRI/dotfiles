{ config, ... }:

{
  services.samba = {
    enable = config.services.transmission.enable;
    openFirewall = true;

    settings = {
      downloads = {
        path = "/storage/transmission/downloads";
        browseable = "yes";
        writeable = "no";
        public = "yes";
      };
      uploads = {
        path = "/storage/uploads";
        browseable = "yes";
        writeable = "yes";
        public = "yes";
      };
    };
  };
}
