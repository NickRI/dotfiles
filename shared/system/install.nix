{ pkgs, ... }:
let
  wormhole-drop = import ../tools/wormhole-drop {
    inherit pkgs;
  };

  install = pkgs.writeShellScriptBin "install-dotfiles" ''
    #!/usr/bin/env bash

    set -e

    logrun() {
      echo "+ $*"
      "$@"
    }

    logrun nmtui connect

    if [ ! -f "$HOME/.ssh/id_ed25519" ] || [ ! -f "$HOME/.ssh/nix-secrets" ]; then
      read -p "Enter wormhole-drop listen address (leave empty for 0.0.0.0:80): " listen
      if [ -z "$listen" ]; then
        listen="0.0.0.0:80"
      fi

      logrun ${wormhole-drop}/bin/wormhole-drop -listen $listen -file1=$HOME/.ssh/id_ed25519 -file2=$HOME/.ssh/nix-secrets
      logrun chmod 600 ~/.ssh/id_ed25519 ~/.ssh/nix-secrets
    fi

    if [ ! -d $HOME/dotfiles ]; then
      logrun git clone git@github.com:nickRI/dotfiles
    fi

    if [ ! -d $HOME/dotfiles/nix-secrets ]; then
      logrun git clone git@github.com:nickRI/nix-secrets.git $HOME/dotfiles/nix-secrets
    fi

    echo "Rewrite flake secret path"

    logrun nix flake lock $HOME/dotfiles --update-input sops-secrets --override-input sops-secrets path:$HOME/dotfiles/nix-secrets

    configuration=$(nix flake show --json $HOME/dotfiles | nix run "nixpkgs#jq" -- -r '.nixosConfigurations | keys[]' | nix run "nixpkgs#fzf" -- --header="Please select your configuration:" --prompt="configuration: ")

    disko_mode=$(echo "format,mount;destroy,format,mount;destroy;format;mount;unmount" | tr ';' '\n' | fzf --header="Please select your format mode for disko:" --prompt="Format mode: ")

    read -p "Enter optional substituters (leave empty for https://ncps.nas.firefly.red): " substituters
    if [ -n "$substituters" ]; then
      nix_options="--option substituters $substituters"
    else
      nix_options="--option substituters https://ncps.nas.firefly.red"
    fi

    logrun sudo nix run $nix_options "github:nix-community/disko" -- --flake "$HOME/dotfiles#$configuration" --mode $disko_mode

    logrun lsblk

    echo "Process age key"

    echo "Your key from $HOME/.ssh/nix-secrets: $(ssh-keygen -f $HOME/.ssh/nix-secrets -y | nix run nixpkgs#ssh-to-age)"
    echo "Available sops keys $HOME/.ssh/nix-secrets: $(cat $HOME/dotfiles/nix-secrets/.sops.yaml)"

    sopsKeyFile=$(nix eval --raw $HOME/dotfiles#nixosConfigurations.work-laptop.config.sops.age.keyFile)

    logrun sudo nix run nixpkgs#ssh-to-age  -- -i $HOME/.ssh/nix-secrets -private-key -o /mnt$sopsKeyFile

    logrun sudo nixos-install $nix_options --flake "$HOME/dotfiles#$configuration" --root /mnt --no-root-password

    echo "Delete master age key"

    logrus sudo rm /mnt$sopsKeyFile
  '';
in
{
  environment.systemPackages = [
    install
  ];

}
