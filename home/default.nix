{ config, unstable, ... }:

{
  imports = [
    ./base.nix
    ../flatpak
  ];

  config = {
    home.packages = with unstable; [
      _1password
      _1password-gui
    ];
  };
}