{...}:

{
    imports = [
      ../../utils/autostart.nix
      ./mime.nix # need to include first to correct override
      ./gnome.nix
      ./1password.nix
      ./shell.nix
      ./golang
      ./rust.nix
    ];
}