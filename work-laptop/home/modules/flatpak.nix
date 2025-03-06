{ flatpaks, ... }:

{
  imports = [ flatpaks.homeManagerModules.nix-flatpak ];

  config = {

    services = {
      flatpak = {
        enable = true;

        uninstallUnmanaged = true;

        update = {
          onActivation = true;
          auto = {
            enable = true;
            onCalendar = "weekly";
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
