{inputs, config, pkgs, lib, ...}:

{
    imports = [
      ./autostart.nix
      ./gnome.nix
      ./golang.nix
      ./rust.nix
      ./mime.nix
    ];
}