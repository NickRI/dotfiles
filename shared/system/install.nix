{ pkgs, ... }:
let
  install = pkgs.writeShellScriptBin "install-dotfiles" ''
    #!/usr/bin/env bash

    set -e

    logrun() {
      echo "+ $*"
      "$@"
    }

    if [ ! -f $HOME/.ssh/id_ed25519.pub ]; then
      ssh-keygen -t ed25519 -C "nixos@hostname" -f $HOME/.ssh/id_ed25519 -N ""
    fi

    cat $HOME/.ssh/id_ed25519.pub
    read -p "You need to add this key to the https://github.com/settings/ssh/new, press enter when ready to go"

    if [ ! -d $HOME/dotfiles ]; then
     logrun git clone git@github.com:nickRI/dotfiles
    fi

    if [ ! -d $HOME/dotfiles/nix-secrets ]; then
      logrun git clone git@github.com:nickRI/nix-secrets.git $HOME/dotfiles/nix-secrets
    fi

    echo "Rewrite flake secret path"

    logrun sed -i "s|git+ssh://git@github.com/NickRI/nix-secrets.git?ref=main&shallow=1|path:$HOME/dotfiles/nix-secrets|" $HOME/dotfiles/flake.nix

    configuration=$(nix flake show --json $HOME/dotfiles | nix run "nixpkgs#jq" -- -r '.nixosConfigurations | keys[]' | nix run "nixpkgs#fzf" -- --header="Please select your configuration:" --prompt="configuration: ")

    read -p "Enter disko mode could be either destroy, format, mount, unmount, format,mount or destroy,format,mount (leave empty for format,mount): " disko_mode
    if [ -z "$disko_mode" ]; then
      disko_mode="format,mount"
    fi

    read -p "Enter optional substituters (leave empty for https://ncps.nas.firefly.red): " substituters
    if [ -n "$substituters" ]; then
      nix_options="--option substituters $substituters"
    else
      nix_options="--option substituters https://ncps.nas.firefly.red"
    fi

    logrun sudo nix run $nix_options "github:nix-community/disko" -- --flake "$HOME/dotfiles#$configuration" --mode $disko_mode

    logrun lsblk

    logrun sudo nixos-install $nix_options --flake "$HOME/dotfiles#$configuration" --root /mnt --no-root-password
  '';
in
{
  environment.systemPackages = [
    install
  ];

}
