# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{
  config,
  pkgs,
  grub-themes,
  lib,
  ...
}@args:

{
  imports = [
    # Include the results of the hardware scan.
    ./networking.nix
    ./disk-config.nix
    ../../shared/system/i18n.nix
    (import ../../shared/system/sops.nix (
      args
      // {
        sops-file = "tv.yaml";
      }
    ))
  ];

  # Bootloader.
  boot.loader = {
    timeout = 3;

    grub = {
      enable = true;
      efiSupport = true;
      theme = grub-themes.packages.${pkgs.stdenv.hostPlatform.system}.hyperfluent;
    };

    efi.canTouchEfiVariables = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  sops.secrets."user-password".neededForUsers = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.journald.extraConfig = "
    SystemMaxUse=256M
  ";

  nix = {
    optimise.automatic = true;
    gc = {
      options = "--delete-older-than 7d";
      automatic = true;
    };
    settings = {
      substituters = lib.mkForce [
        "https://ncps.nas.firefly.red"
      ];
      trusted-public-keys = [
        "nas-server:CHFTyOLXZW0CjAs+4DnXPG3xYne4xhNCIxPRPZ8geG4="
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "tv" ];
    };
  };

  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tv = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "video"
      "input"
      "render"
      "networkmanager"
      "wheel"
    ]; # Enable ‘sudo’ and other for the user.
    hashedPasswordFile = config.sops.secrets."user-password".path;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keyFiles = [ ../../shared/files/authorized_keys ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    inetutils
    exiftool
    ffmpeg
    wget
    htop
    file
    tree
    unixtools.xxd
  ];

  services = {
    xserver = {
      enable = true;
      desktopManager.kodi = {
        enable = true;

        package = pkgs.kodi.withPackages (
          p: with p; [
            pvr-iptvsimple
            youtube
            (pkgs.kodiPackages.callPackage ./modules/lang-ru.nix { })
            (pkgs.kodiPackages.callPackage ./modules/gismeteo.nix { })
          ]
        );
      };
    };

    displayManager = {
      enable = true;
      defaultSession = "kodi";
      autoLogin.user = "tv";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.zsh.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PasswordAuthentication = false;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
