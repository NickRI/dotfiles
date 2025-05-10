{ pkgs, ... }:
let
  install = pkgs.writeShellScriptBin "install-dotfiles" ''
    #!/usr/bin/env bash

    set -e

    logrun() {
      echo "+ $*"
      "$@"
    }

    if [ ! -f .ssh/id_ed25519 ]
    then
      echo -n "Paste your id_ed25519: "
      read -s id_ed25519

      mkdir .ssh
      echo $id_ed25519 > .ssh/id_ed25519
      chmod 600 .ssh/id_ed25519
    fi

    if [ ! -d ./dotfiles ]; then
     logrun git clone https://github.com/nickRI/dotfiles
    fi

    if [ ! -d ./dotfiles/nix-secrets ]; then
      logrun git clone git@github.com:NickRI/nix-secrets.git ./dotfiles/nix-secrets
    fi

    echo "Rewrite flake secret path"

    logrun sed -i "s|git+ssh://git@github.com/NickRI/nix-secrets.git?ref=main&shallow=1|path:$(pwd)/nix-secrets|" ./dotfiles/flake.nix

    configuration=$(nix flake show --json | nix run "nixpkgs#jq" -- -r '.nixosConfigurations | keys[]' | nix run "nixpkgs#fzf" -- --header="Please select your configuration:" --prompt="configuration: ")
    disko_mode=$(echo -e "mount\nformat\ndestroy" | nix run "nixpkgs#fzf" -- --header="Please select disko mode:" --prompt="disko_mode: ")
    installer=$(echo -e "disko-install\nnixos-anywhere" | nix run "nixpkgs#fzf" -- --header="Please select installer:" --prompt="installer: ")


    case "$installer" in
       "disko-install")
          logrun sudo nix run "github:nix-community/disko/latest#disko-install" -- --flake "./dotfiles#\$configuration" --mode "$disko_mode"
          ;;
       "nixos-anywhere")
          read -p "Please enter remote user@host: " target_host
          logrun nix run "github:nix-community/nixos-anywhere" -- --disko-mode "$disko_mode" --flake "./dotfiles#\$configuration" --target-host "$target_host"
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
