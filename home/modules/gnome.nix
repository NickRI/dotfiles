{inputs, config, pkgs, lib, ...}:

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

        favorite-apps = [
          "chromium-browser.desktop"
          "org.telegram.desktop.desktop"
          "discord.desktop"
          "slack.desktop"
          "goland.desktop"
          "datagrip.desktop"
          "com.getpostman.Postman.desktop"
          "org.gnome.Calendar.desktop"
          "Mailspring.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      "org/gnome/desktop/peripherals/mouse" = {
        natural-scroll = true;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = true;
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/mutter" = {
        overlay-key = "Super_R";
        experimental-features = ["scale-monitor-framebuffer"];
      };

      "org/gnome/desktop/input-sources" = {
        per-window = true;
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
        night-light-temperature = lib.hm.gvariant.mkUint32 3260;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "terminal";
        command = "gnome-terminal";
        binding = "<Shift><Control>x";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "monitor";
        command = "gnome-system-monitor";
        binding = "<Shift><Control>m";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "1password";
        command = "1password";
        binding = "<Shift><Control>p";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = "1password search";
        command = "1password --quick-access";
        binding = "<Shift><Control>slash";
      };
    };

    gtk = {
      enable = true;

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

#      theme = {
#        name = "palenight";
#        package = pkgs.palenight-theme;
#      };
#
#      cursorTheme = {
#        name = "Numix-Cursor";
#        package = pkgs.numix-cursor-theme;
#      };

      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };

    home.packages = with pkgs; [
      gnome.gnome-tweaks
      gnome.gnome-software
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