{ config, ... }:

{
  config = {
    services = {
      flatpak = {
        enable = true;

        uninstallUnmanaged = true;

        update = {
          onActivation = true;
          auto = {
            enable = true;
            onCalendar = "weekly"; # Default value
          };
        };

        packages = [
          "com.boxy_svg.BoxySVG"
          "com.ktechpit.colorwall"
          "com.dropbox.Client"
          "com.getpostman.Postman"
          "dev.vencord.Vesktop"
        ];
      };
    };
  };
}