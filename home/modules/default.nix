{inputs, config, pkgs, lib, ...}:

{
    imports = [
      ./autostart.nix
      ./gnome.nix
      ./flatpak.nix
      ./golang.nix
    ];
}