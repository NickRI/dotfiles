{ ... }:

{
  imports = [
    ../../../shared/home/autostart.nix
    ../../../shared/home/shell.nix
    ../../../shared/home/sops.nix
    ./mime.nix # need to include first than gnome to correct override
    ./gnome.nix
    ./flatpak.nix
    ./golang.nix
    ./rust.nix
    ./vpn.nix
    ./email.nix
  ];
}
