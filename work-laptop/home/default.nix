{
  lib,
  pkgs,
  vsextensions,
  ...
}:

{
  imports = [ ./modules ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nikolai";
  home.homeDirectory = "/home/nikolai";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs.unstable; [
    docker-compose

    slack
    mailspring
    whatsapp-for-linux
    zoom-us

    #    discord
    #    viber
    skypeforlinux
    telegram-desktop

    kubectl

    ledger-live-desktop

    meteo
    anydesk
    qemu

    vlc
    transmission_4
    mission-center

    dejavu_fonts
    powerline-fonts
    meslo-lgs-nf
    nerd-fonts.meslo-lg
    nerd-fonts.dejavu-sans-mono

    xournalpp
    foliate
    libreoffice-qt
    obsidian
    gimp
    inkscape
    graphviz
    pinta

    tradingview
    todoist-electron
    nextcloud-client

    rpi-imager
    impression

    ffmpeg
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  autoStart = with pkgs; [
    meteo
    slack
    mailspring
    telegram-desktop
    todoist-electron
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = { };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/nikolai/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL = "1";
  };

  xdg = {
    enable = true;
    systemDirs.data = [
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];

    configFile."mimeapps.list".force = true;

    portal = {
      enable = true;
      config = {
        preferred = {
          default = lib.mkDefault [ "gtk" ];
        };
      };
      extraPortals = with pkgs.unstable; [
        xdg-desktop-portal-gtk
      ];
    };
  };

  programs = {
    ssh.enable = true;

    git = {
      enable = true;
      userEmail = "nicktt2008@yandex.ru";
      userName = "NickRI";
      signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAj9J0TmP14mZ7UUEETiaR+h/5kh6h19jwQgkYDPQcZ7";
      extraConfig = {
        url."git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
    };

    chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # Metamask
        { id = "gighmmpiobklfepjocnamgkkbiglidom"; } # AdBlock
        { id = "bhhhlbepdkbapadjdnnojkbgioiodbic"; } # Solarflare
        { id = "aiifbnbfobpmeekipheeijimdpnlpgpp"; } # StationWallet
        { id = "egjidjbpglichdcondbcbdnbeeppgdph"; } # TrustWallet
        { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GnomeExtenstion
      ];
    };

    vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = true;

      extensions = with vsextensions.vscode-marketplace; [
        eamodio.gitlens
        jnoortheen.nix-ide
        redhat.vscode-yaml
        quicktype.quicktype
        zxh404.vscode-proto3
        nhoizey.gremlins
        gruntfuggly.todo-tree
        actboy168.tasks
        zhuangtongfa.material-theme
        file-icons.file-icons
        postman.postman-for-vscode
        alefragnani.project-manager
        formulahendry.code-runner
        igorsbitnev.error-gutters
        mikestead.dotenv
        cweijan.vscode-database-client2
        github.vscode-pull-request-github
        ms-azuretools.vscode-docker
      ];

      userSettings = {
        "update.mode" = "none";
        "git.autofetch" = true;
        "files.autoSave" = "onFocusChange";
        "editor.fontFamily" = "Roboto Mono for Powerline";
        "editor.fontSize" = 16;
        "editor.formatOnSave" = true;
        "editor.bracketPairColorization.enabled" = true;
        "terminal.integrated.fontFamily" = "MesloLGS NF";
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.fontLigatures" = true;
        "workbench.colorTheme" = "One Dark Pro Mix";
        "gremlins.showInProblemPane" = true;
        "window.newWindowDimensions" = "maximized";
        "editor.rulers" = [ 80 ];
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "git.confirmSync" = false;
      };

      keybindings = [
        {
          "key" = "shift shift";
          "command" = "workbench.action.showCommands";
        }
        {
          "key" = "ctrl+d";
          "command" = "editor.action.duplicateSelection";
        }
        {
          "key" = "ctrl ctrl";
          "command" = "workbench.action.tasks.runTask";
        }
        {
          "key" = "alt alt";
          "command" = "workbench.action.terminal.toggleTerminal";
        }
      ];
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
