{inputs, config, pkgs, unstable, lib, ...}:

let
  util = import ../../utils/base64.nix {lib = lib;};
in
{
  config = {
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
          "vpn-toggler@rheddes.nl"
          "stocks@infinicode.de"
          "gsconnect@andyholmes.github.io"
        ];

        favorite-apps = [
          "chromium-browser.desktop"
          "org.telegram.desktop.desktop"
          "com.discordapp.Discord.desktop"
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
        edge-tiling = true;
        overlay-key = "Super_R";
        experimental-features = ["scale-monitor-framebuffer"];
      };

      "org/gnome/desktop/input-sources" = {
        per-window = true;
        sources = [
          (mkTuple ["xkb" "us"])
          (mkTuple ["xkb" "ru"])
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
        graph-update-interval = mkInt32 500;
        update-interval = mkInt32 1000;
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

      "org/gnome/shell/extensions/stocks" = {
        ticker-interval = 10;
        ticker-stock-amount = 4;
        position-in-panel = "left";
        ticker-display-variation = "tremendous";
        show-ticker-off-market-prices = true;
        use-provider-instrument-names = true;
        portfolios = util.toBase64 (builtins.readFile ../files/portfolios.json);
      };
    };

    gtk = {
      enable = true;

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

    home.packages = with unstable; [
      gnome.gnome-tweaks
      gnome.gnome-software
      gnome.dconf-editor
      gnome-extension-manager
      gnome.gnome-sound-recorder
    ] ++ (with unstable.gnomeExtensions; [
      appindicator
      blur-my-shell
      caffeine
      vitals
      hibernate-status-button
      user-themes
      vpn-toggler
    ]);

    home.file.".local/share/gnome-shell/extensions/stocks@infinicode.de" = {
      source = ../files/stocks-extension;
      recursive = true;
    };

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