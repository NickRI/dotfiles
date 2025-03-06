{
  pkgs,
  ...
}:

{
  config = {
    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };

    security.pam.u2f = {
      enable = true;
      settings = {
        interactive = true;
        cue = true;
      };
    };

    environment.systemPackages = with pkgs; [
      yubikey-manager
    ];

    users.users.nikolai.packages = with pkgs; [
      yubikey-personalization-gui
      yubikey-manager-qt
      yubioath-flutter
    ];
  };
}
