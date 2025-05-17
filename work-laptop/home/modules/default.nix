{ ... }@args:

{
  imports = [
    ../../../shared/home/autostart.nix
    ../../../shared/home/shell.nix
    (import ../../../shared/home/sops.nix (
      args
      // {
        sops-file = "work-laptop-home.yaml";
      }
    ))
    ./mime.nix # need to include first than gnome to correct override
    ./gnome.nix
    ./flatpak.nix
    ./golang.nix
    ./rust.nix
    ./vpn.nix
    ./email.nix
    ./sync.nix
  ];
}
