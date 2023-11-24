{inputs, config, pkgs, lib, ...}:

{
    imports = [
      ./autostart.nix
      ./gnome.nix
      ./golang.nix
      ./mime.nix
    ];
}