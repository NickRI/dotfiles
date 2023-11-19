{
  description = "NixOS personal configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/main";
    gnome.url = "github:NixOS/nixpkgs/gnome";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
        lib = nixpkgs.lib;
        system = "x86_64-linux";
        pkgs =  import nixpkgs {
          system = system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "mailspring-1.11.0"
            ];
          };
        };
        unstable = import nixpkgs-unstable {
          system = system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "mailspring-1.11.0"
            ];
          };
        };
    in {
      nixosConfigurations = {
        fedora = lib.nixosSystem {
          inherit system;
          inherit pkgs;

          modules = [
            {
              nixpkgs.overlays = [
                (self: super: {
                  gnome = inputs.gnome.legacyPackages.x86_64-linux.gnome;
                })
              ];
            }
            home-manager.nixosModules.home-manager
            inputs.nix-flatpak.nixosModules.nix-flatpak
            ./nixos/configuration.nix
            inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nikolai = import ./home/base.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
              home-manager.extraSpecialArgs = { unstable = unstable; };
            }
          ];
        };
      };
      homeConfigurations = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        nikolai = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
            ./home
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = { unstable = unstable; };
        };
      };
    };
}
