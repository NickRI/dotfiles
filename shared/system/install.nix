{ pkgs, ... }:
let
  wormhole-drop = import ../tools/wormhole-drop {
    inherit pkgs;
  };

  install-dotfiles = pkgs.writeShellScriptBin "install-dotfiles" ''
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
    set -Eeuo pipefail
    trap 'echo "Error on line $LINENO"' ERR

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

    generate_age_key() {
      local key_path="$1"

      local ageFile
      ageFile=$(nix eval --raw ".#$key_path") || {
        return 1
      }

      mkdir -p "$(dirname "$temp$ageFile")"

      nix-shell -p age --run "age-keygen -o $temp$ageFile >/dev/null 2>&1"

      chmod 600 "$temp$ageFile"

      local pubAge
      pubAge=$(nix-shell -p age --run "age-keygen -y $temp$ageFile") || {
        return 1
      }

      printf "%s %s\n" "$pubAge" "$ageFile"
    }

    current_configuration=$(nix flake show --json . | jq -r '.nixosConfigurations | keys[]' | fzf --header="Please select current configuration:" --prompt="current: ")
    install_configuration=$(nix flake show --json . | jq -r '.nixosConfigurations | keys[]' | fzf --header="Please select install configuration:" --prompt="install: ")
    user_name=$(nix eval ".#nixosConfigurations.$install_configuration.config.users.users" --json | jq -r 'to_entries | map(select(.value.isNormalUser == true)) | .[0].key')


    echo "Try to add new age keys"
    needsSopsChange=false

    if nix eval ".#nixosConfigurations.$install_configuration.config.sops.age.keyFile" >/dev/null 2>&1; then
      system_buff=$(mktemp)
      if generate_age_key "nixosConfigurations.$install_configuration.config.sops.age.keyFile" > $system_buff; then
        read -r pub_age_system sys_age_file < $system_buff
        echo "System age set properly [$pub_age_system] $sys_age_file"
        needsSopsChange=true
      else
        echo "System age config exist but generation failed! Exit!"
        exit 1
      fi
    else
      echo "System sops configuration does not exits!"
    fi

    if nix eval ".#nixosConfigurations.$install_configuration.config.home-manager.users.$user_name.sops.age.keyFile" >/dev/null 2>&1; then
      home_buff=$(mktemp)
      if generate_age_key "nixosConfigurations.$install_configuration.config.home-manager.users.$user_name.sops.age.keyFile" > $home_buff; then
        read -r pub_age_home home_age_file < $home_buff
        echo "Home-manager age set properly [$pub_age_home] $home_age_file"
        needsSopsChange=true
      else
        echo "Home-manager age config exist but generation failed! Exit!"
        exit 1
      fi
    else
      echo "Home-manager sops configuration does not exits!"
    fi

    if [ "$needsSopsChange" = true ]; then
      echo "Sops keys were changed, need to update nix-secrets"

      master_age_file=$(nix eval --raw .#nixosConfigurations.$current_configuration.config.sops.age.keyFile)

      if [ ! -f $master_age_file ]; then
        echo "You need to have real generated $master_age_file !"
        exit 1
      fi

      echo "Download nix-secrets"

      if [ ! -d ./nix-secrets ]; then
        logrun git clone git@github.com:nickRI/nix-secrets.git $working_dir/nix-secrets
      fi

      selected_rule=$(yq '.creation_rules[].path_regex' $working_dir/nix-secrets/.sops.yaml | fzf --prompt="Select needed secret file: ")

      if [ -n "''${pub_age_system:-}" ]; then
        yq -i \
          "(.creation_rules[] | select(.path_regex == \"$selected_rule\").key_groups[0].age) += [\"$pub_age_system\"]" \
          "$working_dir/nix-secrets/.sops.yaml"
      fi

      if [ -n "''${pub_age_home:-}" ]; then
        yq -i \
          "(.creation_rules[] | select(.path_regex == \"$selected_rule\").key_groups[0].age) += [\"$pub_age_home\"]" \
          "$working_dir/nix-secrets/.sops.yaml"
      fi


      echo "Need to update sops files"

      export SOPS_AGE_KEY=$(sudo cat $master_age_file)

      logrun sops --config ./nix-secrets/.sops.yaml updatekeys --yes ./nix-secrets/$(echo $selected_rule | sed 's/.$//')

      echo "Rewrite flake secret path"

      logrun nix flake update --flake $working_dir sops-secrets --override-input sops-secrets path:$working_dir/nix-secrets
    else
        echo "Sops keys wasn't generated, skipped"
    fi


    echo "Start installation"

    chownIfNeeded=""
    if [ -n "''${home_age_file:-}" ]; then
      chownIfNeeded="--chown $home_age_file 1000:100"
    fi

    logrun nix run github:nix-community/nixos-anywhere -- "$chownIfNeeded" --extra-files "$temp" --flake ".#$install_configuration" "$@"

    if [ "$needsSopsChange" = true ]; then
      echo "DONE! Don't forget to pack and save public ''${pub_age_system:-} & ''${pub_age_home:-} in ./nix-secrets/"
    else
      echo "Just done, cleanup"
    fi
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
