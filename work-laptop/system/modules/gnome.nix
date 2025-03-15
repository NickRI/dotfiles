{ pkgs, ... }:

{
  config = {

    # Configure keymap in X11
    services.xserver = {
      # Disable the X11 windowing system.
      enable = true;

      xkb.layout = "us";

      excludePackages = [ pkgs.xterm ];
    };

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Taken from https://github.com/NixOS/nixpkgs/issues/171136#issuecomment-2449781029
    security.pam.services.login.enableGnomeKeyring = true;

    services.udev.packages = with pkgs; [ gnome-settings-daemon ];

    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-tour
        gnome.gnome-shell-extensions
        kgx
      ])
      ++ (with pkgs; [
        epiphany
        geary
        totem
      ]);

    services.gnome.sushi.enable = true;

    programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
  };
}
