{config, lib, pkgs, ...}:

{
  config = {
    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Taken from https://github.com/NixOS/nixpkgs/issues/171136#issuecomment-1627779037
    security.pam.services.login.fprintAuth = false;
    # similarly to how other distributions handle the fingerprinting login
    security.pam.services.gdm-fingerprint = lib.mkIf (config.services.fprintd.enable) {
      text = ''
        auth       required                    pam_shells.so
        auth       requisite                   pam_nologin.so
        auth       requisite                   pam_faillock.so      preauth
        auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
        auth       optional                    pam_permit.so
        auth       required                    pam_env.so
        auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
        auth       optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so

        account    include                     login

        password   required                    pam_deny.so

        session    include                     login
        session    optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
      '';
    };

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