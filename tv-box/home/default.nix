{ pkgs, ... }@args:

{
  imports = [
    ./modules/youtube.nix
    ./modules/iptv.nix
    ./modules/weather.nix
    ./modules/estuary.skin.nix
    ../../shared/home/shell.nix
    (import ../../shared/home/sops.nix (
      args
      // {
        sops-file = "tv.yaml";
      }
    ))
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "tv";
  home.homeDirectory = "/home/tv";

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

  programs = {
    ssh = {
      enableDefaultConfig = false;
      enable = true;
    };
    git.enable = true;

    kodi = {
      enable = true;
      settings = {
        showexitbutton = "false";
        locale = {
          language = "resource.language.ru_ru";
          country = "Russia";
        };
      };
      sources = {
        videos = {
          path = "smb://nas.firefly.red/downloads/";
          allowsharing = "true";
        };
        movies = {
          path = "smb://nas.firefly.red/downloads/";
          allowsharing = "true";
        };
        music = {
          path = "smb://nas.firefly.red/downloads/";
          allowsharing = "true";
        };
        files = {
          path = "smb://nas.firefly.red/downloads/";
          allowsharing = "true";
        };
      };
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
