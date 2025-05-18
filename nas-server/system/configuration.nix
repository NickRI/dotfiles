# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{
  grub-themes,
  config,
  pkgs,
  ...
}@args:

{
  imports = [
    # Include the results of the hardware scan.
    ./networking.nix
    ./disk-config.nix
    ./modules
    ../../shared/system/i18n.nix
    (import ../../shared/system/sops.nix (
      args
      // {
        sops-file = "nas.yaml";
      }
    ))
  ];

  # Bootloader.
  boot.loader = {
    timeout = 3;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      theme = grub-themes.packages.${pkgs.system}.hyperfluent;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  hardware.pulseaudio.enable = false;
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
    SystemMaxUse=512M
  ";

  nix.settings = {
    extra-platforms = config.boot.binfmt.emulatedSystems;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "nas" ];
  };

  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nas = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ]; # Enable ‘sudo’ docker and other for the user.
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
    openssl
    gnumake
    unixtools.xxd
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.zsh.enable = true;

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig" --impure
    '';
  };

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
