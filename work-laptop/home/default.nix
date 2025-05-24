{
  lib,
  pkgs,
  ...
}:
let
  upkgs = pkgs.unstable;
in
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
  home.packages = with upkgs; [
    code-cursor

    docker-compose

    slack
    whatsapp-for-linux
    zoom-us

    #    discord
    #    viber
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
    passes

    tradingview
    todoist-electron

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

  autoStart = with upkgs; [
    meteo
    slack
    thunderbird
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

  home.shellAliases = {
    "sops-master" =
      "SOPS_AGE_KEY=$(op item get hscy7ap6gqdv3dqoe55oqbgrui --reveal --fields private_key | nix run nixpkgs#ssh-to-age -- -private-key) sops";
  };

  xdg = {
    enable = true;

    configFile."mimeapps.list".force = true;

    portal = {
      enable = true;
      config = {
        preferred = {
          default = lib.mkDefault [ "gtk" ];
        };
      };
      extraPortals = with upkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };

  programs = {
    ssh.enable = true;

    git = {
      enable = true;
      package = upkgs.git;
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
      package = upkgs.chromium;
      extensions = [
        { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # Metamask
        { id = "gighmmpiobklfepjocnamgkkbiglidom"; } # AdBlock
        { id = "bhhhlbepdkbapadjdnnojkbgioiodbic"; } # Solarflare
        { id = "aiifbnbfobpmeekipheeijimdpnlpgpp"; } # StationWallet
        { id = "egjidjbpglichdcondbcbdnbeeppgdph"; } # TrustWallet
        { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GnomeExtenstion
        { id = "meimoidfecamngeoanhnpdjjdcefoldn"; } # Fireflies
      ];
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
