{ config, lib, pkgs, flatpaks, ... }:

{
  imports = [
    ./modules
    flatpaks.homeManagerModules.nix-flatpak
  ];

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
    jetbrains.goland
    jetbrains.datagrip

    docker-compose

    slack
    mailspring
    whatsapp-for-linux
    zoom-us

    gsmartcontrol
#    discord
#    viber
    skypeforlinux
    telegram-desktop

    kubectl

    denaro
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

  services = {
    flatpak = {
      enable = true;

      uninstallUnmanaged = true;

      update = {
        onActivation = true;
        auto = { enable = true; onCalendar = "weekly"; };
      };

      packages = [
        "com.boxy_svg.BoxySVG"
        "com.ktechpit.colorwall"
        "com.dropbox.Client"
        "com.getpostman.Postman"
        "dev.vencord.Vesktop"
        "com.surfshark.Surfshark"
      ];
    };
  };

  autoStart = with pkgs; [
    meteo
    slack
    mailspring
    telegram-desktop
    todoist-electron
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {};

  home.activation.certsForPostman = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.openssl}/bin/openssl req -subj '/C=US/CN=Postman Proxy' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 \
    -keyout $HOME/.var/app/com.getpostman.Postman/config/Postman/proxy/postman-proxy-ca.key \
    -out $HOME/.var/app/com.getpostman.Postman/config/Postman/proxy/postman-proxy-ca.crt
  '';

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

  xdg.enable = true;
  xdg.systemDirs.data = [
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];
  xdg.configFile."mimeapps.list".force = true;

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
        { id = "ailoabdmgclmfmhdagmlohpjlbpffblp"; } # Surfshark VPN
      ];
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
