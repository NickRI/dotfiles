{ config, unstable, ... }:

{
  imports = [
    ./nixos.nix
    ../flatpak
  ];

  config = {
    home.packages = with unstable; [
      _1password
      _1password-gui
    ];
  };
}