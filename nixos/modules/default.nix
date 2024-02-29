{ ... }: {
  imports = [
    ./gnome.nix
    ./usb-wakeup-disable.nix
    ./suspend-and-hibernate.nix
  ];
}