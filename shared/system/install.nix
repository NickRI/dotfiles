{ pkgs, ... }:
let
  wormhole-drop = import ../tools/wormhole-drop {
    inherit pkgs;
  };

  install-dotfiles = pkgs.writeShellScriptBin "install-dotfiles" ''
    #!/usr/bin/env bash

    set -e

    logrun() {
      echo "+ $*"
      "$@"
    }

    export GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no'

    logrun nmtui connect

    if [ ! -f "$HOME/.ssh/id_ed25519" ] || [ ! -f "$HOME/.ssh/nix-secrets" ]; then
      read -p "Enter wormhole-drop listen address (leave empty for 0.0.0.0:8080): " listen
      if [ -z "$listen" ]; then
        listen="0.0.0.0:8080"
      fi

      logrun mkdir -p $HOME/.ssh
      logrun ${wormhole-drop}/bin/wormhole-drop -listen $listen -file1=$HOME/.ssh/id_ed25519 -file2=$HOME/.ssh/nix-secrets
      logrun chmod 600 $HOME/.ssh/id_ed25519 $HOME/.ssh/nix-secrets
    fi

    if [ ! -d $HOME/dotfiles ]; then
      logrun git clone git@github.com:nickRI/dotfiles
    fi

    if [ ! -d $HOME/dotfiles/nix-secrets ]; then
      logrun git clone git@github.com:nickRI/nix-secrets.git $HOME/dotfiles/nix-secrets
    fi

    echo "Rewrite flake secret path"

    logrun nix flake update --flake $HOME/dotfiles sops-secrets --override-input sops-secrets path:$HOME/dotfiles/nix-secrets

    configuration=$(nix flake show --json $HOME/dotfiles | jq -r '.nixosConfigurations | keys[]' | fzf --header="Please select your configuration:" --prompt="configuration: ")

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

    sopsKeyFile=$(nix eval --raw $HOME/dotfiles#nixosConfigurations.$configuration.config.sops.age.keyFile)

    logrun sudo mkdir -p $sopsKeyFile
    logrun sudo nix run nixpkgs#ssh-to-age  -- -i $HOME/.ssh/nix-secrets -private-key -o /mnt$sopsKeyFile

    logrun sudo nixos-install $nix_options --flake "$HOME/dotfiles#$configuration" --root /mnt --no-root-password

    echo "Delete master age key"

    logrun sudo rm /mnt$sopsKeyFile
  '';

  install-remote = pkgs.writeShellScriptBin "install-remote" ''
    #!/usr/bin/env bash

    set -e

    logrun() {
      echo "+ $*"
      "$@"
    }

    export GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no'

    temp=$(mktemp -d)
    working_dir=$(pwd)

    cleanup() {
      rm -rf "$temp"
    }
    trap cleanup EXIT

    current_configuration=$(nix flake show --json . | jq -r '.nixosConfigurations | keys[]' | fzf --header="Please select current configuration:" --prompt="configuration: ")

    echo "Generate new ssh ed25519_key"

    logrun install -d -m755 "$temp/etc/ssh"

    logrun ssh-keygen -t ed25519 -N "" -f "$temp/etc/ssh/ssh_host_ed25519_key"

    logrun chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
    logrun chmod 644 "$temp/etc/ssh/ssh_host_ed25519_key.pub"

    age_key=$(nix run nixpkgs#ssh-to-age -- -i "$temp/etc/ssh/ssh_host_ed25519_key.pub")

    echo "Download nix-secrets"

    if [ ! -d ./nix-secrets ]; then
      logrun git clone git@github.com:nickRI/nix-secrets.git $working_dir/nix-secrets
    fi

    echo "Need to add new public age key"

    selected_rule=$(yq '.creation_rules[].path_regex' $working_dir/nix-secrets/.sops.yaml | fzf --prompt="Select needed secret file: ")

    logrun yq -i "(.creation_rules[] | select(.path_regex == \"$selected_rule\").key_groups[0].age) += [\"$age_key\"]" $working_dir/nix-secrets/.sops.yaml

    master_age_file=$(nix eval --raw .#nixosConfigurations.$current_configuration.config.sops.age.keyFile)

    if [ ! -f $master_age_file ]; then
      echo "You need to have real generated $master_age_file !"
      exit 1
    fi

    export SOPS_AGE_KEY=$(sudo cat $master_age_file)

    logrun sops --config ./nix-secrets/.sops.yaml updatekeys --yes ./nix-secrets/$(echo $selected_rule | sed 's/.$//')

    echo "Rewrite flake secret path"
    logrun nix flake update --flake $working_dir sops-secrets --override-input sops-secrets path:$working_dir/nix-secrets

    install_configuration=$(nix flake show --json . | jq -r '.nixosConfigurations | keys[]' | fzf --header="Please select your install configuration:" --prompt="install: ")

    logrun nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake ".#$install_configuration" "$@"

    echo "DONE! Don't forget to pack and save $age_key for $selected_rule and updatekeys with nix flake update sops-secrets"
  '';
in
{
  environment.systemPackages = [
    pkgs.jq
    pkgs.yq-go
    pkgs.fzf
    install-dotfiles
    install-remote
  ];

}
