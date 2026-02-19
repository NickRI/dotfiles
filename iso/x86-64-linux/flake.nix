{
  description = "NixOS drop-in image for first boot";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosModules = {
        iso-config =
          {
            modulesPath,
            pkgs,
            lib,
            ...
          }:
          {
            imports = [
              "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
              ../../shared/system/install.nix
            ];

            boot = {
              loader.timeout = lib.mkForce 1;
              kernelPackages = pkgs.linuxPackages_latest;
              supportedFilesystems = lib.mkForce [
                "btrfs"
                "reiserfs"
                "vfat"
                "f2fs"
                "xfs"
                "ntfs"
                "cifs"
              ];
            };

            nix = {
              settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              extraOptions = "experimental-features = nix-command flakes";
            };

            users.users.nixos = {
              isNormalUser = true;
              extraGroups = [
                "networkmanager"
                "wheel"
              ];

              openssh.authorizedKeys.keyFiles = [ ../../shared/files/authorized_keys ];
            };

            documentation = {
              enable = lib.mkForce false;
              nixos.enable = lib.mkForce false;
            };

            environment.systemPackages = with pkgs; [
              fzf
              wget
              htop
              file
              gcc
              tree
              openssl
              btop
            ];

            environment.etc.issue.text = ''
              Here is x86-64 linux installer.
              Use nmcli or nmtui to enable internet connection.
              For install use install-dotfiles command.
            '';

            # Enable the OpenSSH daemon.
            services.openssh = {
              enable = true;
              openFirewall = true;
              settings.PasswordAuthentication = false;
            };

            networking = {
              hostName = "x86-64-iso";
              wireless.enable = false;
              networkmanager.enable = true;
              useDHCP = lib.mkDefault true;
              firewall = {
                enable = true;
                allowedTCPPortRanges = [
                  {
                    from = 1;
                    to = 65535;
                  }
                ];
                allowedUDPPortRanges = [
                  {
                    from = 1;
                    to = 65535;
                  }
                ];
              };
            };

            system.stateVersion = "24.11";
          };
      };

      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            self.nixosModules.iso-config
          ];
        };
      };
    };
}
