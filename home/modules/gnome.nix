{inputs, config, pkgs, unstable, lib, ...}:

{
  config = {
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;

        # `gnome-extensions list` for a list
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "blur-my-shell@aunetx"
          "caffeine@patapon.info"
          "Vitals@CoreCoding.com"
          "hibernate-status@dromi"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
      };
    };

    home.packages = with pkgs; [
      gnome.gnome-tweaks
      unstable.gnome.gnome-software
      gnome-extension-manager


      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.vitals
      gnomeExtensions.hibernate-status-button
      gnomeExtensions.user-themes
    ];

    programs = {
      gnome-terminal = {
        enable = true;
        themeVariant = "dark";
        profile = {
          "38b76d40-f796-434f-89e5-2f57f6b28a70" = {
            default = true;
            font = "Meslo LGS NF 12";
            cursorShape = "block";
            visibleName = "personal";
            customCommand = "zsh";
            transparencyPercent = 30;
          };
        };
      };
    };
  };
}