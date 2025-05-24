{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    home.packages =
      with pkgs;
      [
        gnome-tweaks
        dconf-editor
        gnome-software
        gnome-extension-manager
        gnome-sound-recorder
      ]
      ++ (with pkgs.unstable.gnomeExtensions; [
        appindicator
        blur-my-shell
        caffeine
        vitals
        hibernate-status-button
        user-themes
        auto-move-windows
        hide-minimized
      ]);

    dconf.settings = with lib.hm.gvariant; {
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
          "gsconnect@andyholmes.github.io"
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "hide-minimized@danigm.net"
        ];

        favorite-apps = [
          "chromium-browser.desktop"
          "org.telegram.desktop.desktop"
          "dev.vencord.Vesktop.desktop"
          "slack.desktop"
          "goland.desktop"
          "datagrip.desktop"
          "com.getpostman.Postman.desktop"
          "org.gnome.Calendar.desktop"
          "thunderbird.desktop"
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
        edge-tiling = true;
        overlay-key = "Super_R";
        experimental-features = [ "scale-monitor-framebuffer" ];
      };

      "org/gnome/desktop/input-sources" = {
        per-window = true;
        sources = [
          (mkTuple [
            "xkb"
            "us"
          ])
          (mkTuple [
            "xkb"
            "ru"
          ])
        ];
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
        night-light-temperature = mkUint32 3260;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        idle-brightness = mkInt32 30;
        sleep-inactive-battery-timeout = mkInt32 900;
        sleep-inactive-ac-timeout = mkInt32 2700;
        power-button-action = "suspend";
        sleep-inactive-ac-type = "suspend";
        sleep-inactive-battery-type = "suspend";
      };

      "org/gnome/desktop/session" = {
        idle-delay = mkUint32 900; # The number of seconds of inactivity before the session is considered idle.
      };

      "org/gnome/desktop/screensaver" = {
        lock-enabled = true; # Set this to TRUE to lock the screen when the screensaver goes active.
        lock-delay = mkUint32 1800; # The number of seconds after screensaver activation before locking the screen.
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "terminal";
        command = "gnome-terminal";
        binding = "<Shift><Control>x";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "monitor";
        command = "missioncenter";
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

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
        name = "calculator";
        command = "gnome-calculator";
        binding = "<Shift><Control>period";
      };

      "org/gnome/gnome-system-monitor" = {
        graph-update-interval = mkInt32 1000;
        update-interval = mkInt32 1500;
      };

      "org/gnome/shell/extensions/hibernate-status-button" = {
        show-hybrid-sleep = false;
        show-suspend-then-hibernate = false;
      };

      "org/gnome/shell/extensions/caffeine" = {
        enable-fullscreen = true;
        nightlight-control = "for-apps";
        screen-blank = "always";
      };

      "org/gnome/shell/extensions/auto-move-windows" = {
        application-list = [
          "tradingview.desktop:2"
          "ledger-live-desktop.desktop:2"
        ];
      };

      "org/gnome/shell/extensions/vitals" = {
        alphabetize = true;
        fixed-widths = true;
        update-time = mkInt32 5;
        battery-slot = mkInt32 1;
        position-in-panel = mkInt32 0;
        network-speed-format = mkInt32 1;
        hot-sensors = [
          "_processor_usage_"
          "_memory_usage_"
          "__temperature_avg__"
          "__network-rx_max__"
        ];
      };

      "org/gnome/desktop/privacy" = {
        remember-recent-files = true;
        recent-files-max-age = mkInt32 30;

        old-files-age = mkUint32 30;
        remove-old-temp-files = true;
        remove-old-trash-files = true;
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        font-antialiasing = "rgba";
        font-hinting = "slight";
        monospace-font-name = config.gtk.font.name + " 12"; # + toString(config.gtk.font.size); # It's convinient to use
        document-font-name = config.gtk.font.name + " " + toString (config.gtk.font.size); # It's convinient to use
      };

      "org/gnome/desktop/app-folders" = {
        "folder-children" = [
          "Internet"
          "Security"
          "System"
          "AudioVideo"
          "Editors"
          "Configs"
          "Readers"
          "Utilities"
          "Office"
          "Misc"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Internet" = {
        "name" = "Интернет";
        "apps" = [
          "com.github.xeco23.WasIstLos.desktop"
          "Zoom.desktop"
          "AnyDesk.desktop"
          "com.dropbox.Client.desktop"
          "todoist.desktop"
          "org.gnome.Connections.desktop"
          "com.gitlab.bitseater.meteo.desktop"
          "syncthingtray.desktop"
          "com.ktechpit.colorwall.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Security" = {
        "name" = "Безопасность";
        "apps" = [
          "org.gnome.seahorse.Application.desktop"
          "com.surfshark.Surfshark.desktop"
          "1password.desktop"
          "ykman-gui.desktop"
          "com.yubico.authenticator.desktop"
          "yubikey-personalization-gui.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/System" = {
        "name" = "Система";
        "apps" = [
          "org.gnome.Terminal.desktop"
          "io.missioncenter.MissionCenter.desktop"
          "org.gnome.SystemMonitor.desktop"
          "htop.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/AudioVideo" = {
        "name" = "Аудио и видео";
        "apps" = [
          "org.gnome.SoundRecorder.desktop"
          "org.gnome.Music.desktop"
          "vlc.desktop"
          "org.gnome.Snapshot.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Editors" = {
        "name" = "Редакторы";
        "apps" = [
          "org.gnome.TextEditor.desktop"
          "obsidian.desktop"
          "com.boxy_svg.BoxySVG.desktop"
          "pinta.desktop"
          "org.inkscape.Inkscape.desktop"
          "gimp.desktop"
          "com.github.xournalpp.xournalpp.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Configs" = {
        "name" = "Настройки";
        "apps" = [
          "org.gnome.Extensions.desktop"
          "com.mattjakeman.ExtensionManager.desktop"
          "ca.desrt.dconf-editor.desktop"
          "org.gnome.Settings.desktop"
          "org.gnome.tweaks.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Utilities" = {
        "name" = "Утилиты";
        "apps" = [
          "org.gnome.baobab.desktop"
          "org.gnome.DiskUtility.desktop"
          "org.gnome.Logs.desktop"
          "org.gnome.Characters.desktop"
          "org.gnome.font-viewer.desktop"
          "io.gitlab.adhami3310.Impression.desktop"
          "org.gnome.FileRoller.desktop"
          "org.raspberrypi.rpi-imager.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Office" = {
        "name" = "Офис";
        "apps" = [
          "calc.desktop"
          "impress.desktop"
          "writer.desktop"
          "math.desktop"
          "draw.desktop"
          "base.desktop"
          "startcenter.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Misc" = {
        "name" = "Разное";
        "apps" = [
          "cups.desktop"
          "yelp.desktop"
          "simple-scan.desktop"
          "nixos-manual.desktop"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Readers" = {
        "name" = "Чтение";
        "apps" = [
          "org.gnome.Evince.desktop"
          "org.gnome.Loupe.desktop"
          "com.github.johnfactotum.Foliate.desktop"
          "me.sanchezrodriguez.passes.desktop"
        ];
      };

    };

    gtk = {
      enable = true;

      font = {
        name = "Inter Variable";
        size = 10;
        package = pkgs.unstable.inter-nerdfont;
      };

      iconTheme = {
        name = "Qogir-dark";
        package = pkgs.qogir-icon-theme;
      };

      #      theme = {
      #        name = "palenight";
      #        package = pkgs.palenight-theme;
      #      };
      #
      cursorTheme = {
        name = "Qogir-dark";
        package = pkgs.qogir-icon-theme;
      };
    };

    xdg = {
      mimeApps = lib.mkIf (config.xdg.mimeApps.enable) {
        defaultApplications = {
          "text/calendar" = "org.gnome.Calendar.desktop";
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/gif" = "org.gnome.Loupe.desktop";
          "image/png" = "org.gnome.Loupe.desktop";
          "image/tiff" = "org.gnome.Loupe.desktop";
          "image/webp" = "org.gnome.Loupe.desktop";
          "application/pdf" = [ "org.gnome.Evince.desktop" ];
          "text/plain" = "org.gnome.TextEditor.desktop";
        };
      };

      portal = lib.mkIf (config.xdg.portal.enable) {
        config = {
          preferred = {
            default = [ "gnome" ];
          };
        };
        extraPortals = with pkgs.unstable; [
          xdg-desktop-portal-gnome
        ];
      };
    };

    programs = {
      gnome-terminal = {
        enable = true;
        themeVariant = "dark";
        profile = {
          "38b76d40-f796-434f-89e5-2f57f6b28a70" = {
            default = true;
            font = "Meslo LGS NF 13.5";
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
