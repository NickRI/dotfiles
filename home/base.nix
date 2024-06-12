{ config, lib, pkgs, unstable, ... }:

{
  imports = [ ./modules ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nikolai";
  home.homeDirectory = "/home/nikolai";
  home.shellAliases = {
     ".." = "cd ..";
     "..." = "cd ../..";
     ll = "ls -lah";
     nix-switch = "nixos-rebuild --use-remote-sudo switch --flake ~/.dotfiles";
     nix-boot = "nixos-rebuild --use-remote-sudo boot --flake ~/.dotfiles";
     nix-update = "nix flake update --commit-lock-file ~/.dotfiles";
     nix-cleanup = "nix store optimise && nix-collect-garbage -d";
     manager-switch = "home-manager switch --flake ~/.dotfiles";
     nix-profile-list = "sudo nix --extra-experimental-features nix-command profile history --profile /nix/var/nix/profiles/system";
     nix-profile-wipe = "sudo nix --extra-experimental-features nix-command profile wipe-history --profile /nix/var/nix/profiles/system";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with unstable; [
    jetbrains.goland
    jetbrains.datagrip

    lazydocker
    docker-compose

    slack
    mailspring
    whatsapp-for-linux
#    discord
#    viber
    skypeforlinux
#    telegram-desktop

    kubectl

    denaro
    ledger-live-desktop

    meteo
    anydesk
    flatpak
    vlc
    xournalpp
    transmission-gtk
    mission-center

    dejavu_fonts
    powerline-fonts
    meslo-lgs-nf
    nerdfonts

    libreoffice-fresh
    gimp
    inkscape

    tradingview

    nvd

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

  autostart = with unstable; [
    _1password-gui
    meteo
    slack
    mailspring
    {
      pname = "org.telegram.desktop";
      desktopFile = ./files/org.telegram.desktop.desktop;
    }
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".p10k.zsh".source = ./files/.p10k.zsh;
    ".local/share/applications/ledger-live-desktop.desktop".source = ./files/ledger-live-desktop.desktop;
    ".config/1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    vault = "work"
    '';
    ".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    '';
  };

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

  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.systemDirs.data = [
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];
  xdg.configFile."mimeapps.list".force = true;

  programs = {
    bash.enable = true;

    ssh = {
      enable = true;
      extraConfig = ''
      IdentityAgent = ~/.1password/agent.sock
      '';
    };

    git = {
        enable = true;
        userEmail = "nicktt2008@yandex.ru";
        userName = "NickRI";
        extraConfig = {
            url."git@github.com:" = {
                insteadOf = "https://github.com/";
            };
        };
    };

    gh = {
        enable = true;
        settings = {
            # What protocol to use when performing git operations. Supported values: ssh, https
            git_protocol = "ssh";
            # What editor gh should run when creating issues, pull requests, etc. If blank, will refer to environment.
            # editor = ;
            # When to interactively prompt. This is a global config that cannot be overridden by hostname. Supported values: enabled, disabled
            prompt = "enabled";
            # A pager program to send command output to, e.g. "less". Set the value to "cat" to disable the pager.
            # pager = ;
            # Aliases allow you to create nicknames for gh commands
            aliases = {
                co = "pr checkout";
            };
            # The path to a unix socket through which send HTTP connections. If blank, HTTP traffic will be handled by net/http.DefaultTransport.
            # http_unix_socket = ;
            # What web browser gh should use when opening URLs. If blank, will refer to environment.
            browser = "chromium";
        };
        extensions = [
            pkgs.gh-dash
        ];
    };

    zsh = {
        enable = true;
        initExtra = ''
            source ~/.p10k.zsh
        '';

        oh-my-zsh = {
            enable = true;
            theme = "robbyrussell";
            plugins = [ "git" "sudo" "golang" "docker" "themes" "1password" ];
        };

        plugins = [
          {
            name = "zsh-autosuggestions";
            src = unstable.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-autosuggestions";
              rev = "v0.7.0";
              sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
            };
          }
          {
            name = "powerlevel10k";
            src = unstable.fetchFromGitHub {
              owner = "romkatv";
              repo = "powerlevel10k";
              rev = "v1.19.0";
              sha256 = "+hzjSbbrXr0w1rGHm6m2oZ6pfmD6UUDBfPd7uMg5l5c=";
            };
            file = "powerlevel10k.zsh-theme";
          }
        ];
    };

    chromium = {
      enable = true;
      extensions = [
        { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # Metamask
        { id = "gighmmpiobklfepjocnamgkkbiglidom"; } # AdBlock
        { id = "bhhhlbepdkbapadjdnnojkbgioiodbic"; } # Solarflare
        { id = "aiifbnbfobpmeekipheeijimdpnlpgpp"; } # StationWallet
        { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
        { id = "egjidjbpglichdcondbcbdnbeeppgdph"; } # TrustWallet
        { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GnomeExtenstion
      ];
    };

    jq.enable = true;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
