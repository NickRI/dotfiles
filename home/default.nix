{ config, pkgs, unstable, flatpack, ... }:

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
     switch = "home-manager switch --flake ~/.dotfiles";
  };

  services = {
    flatpak = {
      enable = true;

      update = {
        onActivation = true;
        auto = {
          enable = true;
          onCalendar = "weekly"; # Default value
        };
      };

      packages = [
        "com.boxy_svg.BoxySVG"
        "com.ktechpit.colorwall"
        "com.dropbox.Client"
      ];
    };
  };

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
  home.packages = [
    pkgs.htop
    pkgs.wget
    pkgs.xournalpp
    pkgs.postman

    unstable.jetbrains.goland
    unstable.jetbrains.datagrip

    unstable.slack
    unstable.telegram-desktop
    unstable.mailspring
    unstable.whatsapp-for-linux
    unstable.discord
#    unstable.viber
    unstable.skypeforlinux

    unstable.denaro
    unstable.ledger-live-desktop

    pkgs._1password
    pkgs._1password-gui

    unstable.meteo
    unstable.anydesk
    unstable.flatpak
    unstable.vlc
    unstable.transmission

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


  autostart = [
    unstable._1password-gui
    unstable.meteo unstable.slack
    unstable.telegram-desktop
    unstable.mailspring
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".p10k.zsh".source = ./.p10k.zsh;
  };


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
  };

  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data = [
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];

  programs = {
    bash.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
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
        zplug = {
            enable = true;
            plugins = [
                { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
                { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
            ];
        };
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

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
