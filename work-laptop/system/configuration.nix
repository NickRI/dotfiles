# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{
  grub-themes,
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./networking.nix
    ./disk-config.nix
    ./gnome.nix
    ./modules/ai.nix
    ./modules/yubikey.nix
    ../../shared/system
    ../../shared/system/sops.nix
  ];

  # Bootloader.
  boot.loader = {
    timeout = 3;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      theme = grub-themes.packages.${pkgs.system}.hyperfluent;
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Set your time zone.
  time.timeZone = null;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  hardware.ledger.enable = true;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        ClassicBondedOnly = false;
        ControllerMode = "dual";
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.mesa.drivers ];
    enable32Bit = true;
  };

  security.rtkit.enable = true;

  sops.secrets = {
    "laptop/user-password".neededForUsers = true;
  };

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.flatpak.enable = true;
  services.fprintd.enable = true;
  services.fwupd.enable = true;
  services.fstrim.enable = true;
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "suspend";
    lidSwitchExternalPower = "ignore";
  };

  # Don't let USB devices wake the computer from sleep.
  # nix-shell -p usbutils --run lsusb
  hardware.usb.wakeupDisabled = [
    {
      # Genius usb keyboard
      vendor = "c0f4";
      product = "05c0";
    }
  ];

  nix.settings = {
    extra-platforms = config.boot.binfmt.emulatedSystems;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.nikolai = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ]; # Enable 'sudo' docker and other for the user.
    hashedPasswordFile = config.sops.secrets."laptop/user-password".path;
    shell = pkgs.zsh;
    #   packages = with pkgs; [
    #     firefox
    #     tree
    #   ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    inetutils
    wget
    htop
    file
    gcc
    tree
    openssl
    gnumake
    unixtools.xxd
    xclip
    sops

    nvd
    nix-tree
    nix-du
    nix-index
    nixfmt-rfc-style
    nixd
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.zsh.enable = true;
  programs._1password = {
    enable = true;
    package = pkgs.unstable._1password-cli;
  };
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "nikolai" ];
    package = pkgs.unstable._1password-gui;
  };
  programs.nix-ld.enable = true;
  programs.kdeconnect.enable = true;

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig" --impure
    '';
  };

  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  virtualisation.docker.enable = true;

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
