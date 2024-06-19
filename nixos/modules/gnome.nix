{config, lib, pkgs, ...}:

{
  config = {
    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    security.pam.services.login.fprintAuth = false;

    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

    environment.gnome.excludePackages = (with pkgs; [
      gnome-tour
      kgx
    ]) ++ (with pkgs.gnome; [
      epiphany
      geary
      totem
    ]);

    programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
  };
}