{ pkgs, ... }:
let
  install = pkgs.writeShellScriptBin "install-dotfiles" ''
    #!/usr/bin/env bash

    set -e

    logrun() {
      echo "+ $*"
      "$@"
    }

    if [ ! -d $HOME/.ssh ]; then
      mkdir .ssh
    fi

    if [ ! -f $HOME/.ssh/id_ed25519 ]
    then
      echo "Private key $HOME/.ssh/id_ed25519 not found. You need to add it manually. Abort!"
      exit 1
    fi

    if [ ! -d $HOME/dotfiles ]; then
     logrun git clone https://github.com/nickRI/dotfiles
    fi

    if [ ! -d $HOME/dotfiles/nix-secrets ]; then
      logrun git clone git@github.com:NickRI/nix-secrets.git $HOME/dotfiles/nix-secrets
    fi

    echo "Rewrite flake secret path"

    logrun sed -i "s|git+ssh://git@github.com/NickRI/nix-secrets.git?ref=main&shallow=1|path:$HOME/dotfiles/nix-secrets|" $HOME/dotfiles/flake.nix

    configuration=$(nix flake show --json github:NickRI/dotfiles | nix run "nixpkgs#jq" -- -r '.nixosConfigurations | keys[]' | nix run "nixpkgs#fzf" -- --header="Please select your configuration:" --prompt="configuration: ")
    disko_mode=$(echo -e "mount\nformat\ndestroy" | nix run "nixpkgs#fzf" -- --header="Please select disko mode:" --prompt="disko_mode: ")
    installer=$(echo -e "disko-install\nnixos-anywhere\nnixos-install" | nix run "nixpkgs#fzf" -- --header="Please select installer:" --prompt="installer: ")

    read -p "Enter optional substituters (leave empty for https://ncps.nas.firefly.red): " substituters

    if [ -n "$substituters" ]; then
      nix_options="--option substituters $substituters"
    else
      nix_options="--option substituters https://ncps.nas.firefly.red"
    fi

    case "$installer" in
       "disko-install")
          logrun sudo nix run $nix_options "github:nix-community/disko/latest#disko-install" -- --flake "$HOME/dotfiles#$configuration" --mode "$disko_mode"
          ;;
       "nixos-anywhere")
          read -p "Please enter remote user@host: " target_host
          logrun nix run $nix_options "github:nix-community/nixos-anywhere" -- --disko-mode "$disko_mode" --flake "$HOME/dotfiles#$configuration" --target-host "$target_host"
          ;;
      "nixos-install")
          if [ ! -d /mnt ]; then
            echo "/mnt not found, probably not mounted abort"
            exit 1
          fi
          logrun sudo nixos-install $nix_options --flake "$HOME/dotfiles#$configuration"
          ;;
       *)
          echo "You need to select installer, abort"
    esac
  '';
in
{
  environment.systemPackages = [
    install
  ];
}
