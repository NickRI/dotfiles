{ ... }:

{
  imports = [
    ../../../shared/home/autostart.nix
    ../../../shared/home/shell.nix
    ./mime.nix # need to include first than gnome to correct override
    ./gnome.nix
    ./flatpak.nix
    ./1password.nix
    ./golang
    ./rust.nix
    ./vpn.nix
  ];
}
